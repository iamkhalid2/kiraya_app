import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/room.dart';
import '../utils/error_handler.dart';

class RoomProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference? _rooms;
  List<Room> _roomsList = [];
  String? _userId;
  bool _isLoading = true;
  StreamSubscription<QuerySnapshot>? _roomsSubscription;
  final _tenantRoomCache = <String, MapEntry<String, String>>{};

  List<Room> get rooms => List.unmodifiable(_roomsList);
  bool get isInitialized => _userId != null;
  bool get isLoading => _isLoading;

  void initialize(String? userId) {
    // Always cancel existing subscription first
    _roomsSubscription?.cancel();
    
    if (userId == null) {
      // Handle logout
      _roomsList = [];
      _tenantRoomCache.clear();
      _userId = null;
      _rooms = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Reset state before initializing
    _roomsList = [];
    _tenantRoomCache.clear();
    _isLoading = true;
    notifyListeners();
    
    _userId = userId;
    _rooms = _firestore.collection('users/$userId/rooms');
    
    // Set up new subscription
    _roomsSubscription = _rooms!.snapshots().listen(
      (snapshot) {
        _roomsList = snapshot.docs.map((doc) {
          return Room.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          );
        }).toList()..sort((a, b) => a.number.compareTo(b.number));
        
        _updateTenantRoomCache();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error in rooms subscription: $e');
        _roomsList = [];
        _tenantRoomCache.clear();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _updateTenantRoomCache() {
    _tenantRoomCache.clear();
    for (var room in _roomsList) {
      for (var section in room.sections) {
        if (section.tenantId != null) {
          _tenantRoomCache[section.tenantId!] = MapEntry(room.id!, section.id);
        }
      }
    }
  }

  MapEntry<String, String>? getTenantRoomAssignment(String tenantId) {
    return _tenantRoomCache[tenantId];
  }

  Future<void> addRoom(Room room) async {
    _checkInitialization();

    if (!isRoomNumberAvailable(room.number)) {
      throw Exception('Room ${room.number} already exists');
    }

    try {
      await _rooms!.add(room.toMap());
    } catch (e) {
      throw ErrorHandler.getFormattedErrorMessage(e);
    }
  }

  Future<void> updateRoom(Room room) async {
    _checkInitialization();
    
    if (room.id == null) {
      throw Exception('Invalid room: ID is missing');
    }

    try {
      await _rooms!.doc(room.id).update(room.toMap());
    } catch (e) {
      throw ErrorHandler.getFormattedErrorMessage(e);
    }
  }

  Future<void> deleteRoom(String roomId) async {
    _checkInitialization();

    final room = _roomsList.firstWhere(
      (r) => r.id == roomId,
      orElse: () => throw Exception('Room not found'),
    );

    if (!room.isEmpty) {
      throw Exception('Cannot delete occupied room');
    }

    try {
      await _rooms!.doc(roomId).delete();
    } catch (e) {
      throw ErrorHandler.getFormattedErrorMessage(e);
    }
  }

  Future<void> assignTenant(String roomId, String sectionId, String tenantId) async {
    _checkInitialization();

    try {
      final room = _getRoomById(roomId);
      
      // Check if this tenant is already in this section
      final section = room.getSection(sectionId);
      if (section.tenantId == tenantId) {
        return; // Already assigned to this section, no need to update
      }

      // Check if room can accept the tenant
      if (!room.canAcceptTenant(tenantId)) {
        throw Exception('Room is full');
      }

      // Check if section is available
      if (section.isOccupied && section.tenantId != tenantId) {
        throw Exception('Section is occupied by another tenant');
      }

      // Update the section with the new tenant
      room.updateSection(
        sectionId,
        isOccupied: true,
        tenantId: tenantId,
      );

      // Save changes to Firestore
      await updateRoom(room);
      
      // Update cache
      _tenantRoomCache[tenantId] = MapEntry(roomId, sectionId);
    } catch (e) {
      throw ErrorHandler.getFormattedErrorMessage(e);
    }
  }

  Future<void> removeTenant(String roomId, String sectionId) async {
    _checkInitialization();

    try {
      final room = _getRoomById(roomId);
      final section = room.getSection(sectionId);
      
      if (!section.isOccupied) {
        throw Exception('Section is already vacant');
      }

      room.updateSection(
        sectionId,
        isOccupied: false,
        tenantId: null,
        tenantName: null,
      );

      await updateRoom(room);
    } catch (e) {
      throw ErrorHandler.getFormattedErrorMessage(e);
    }
  }

  List<MapEntry<String, String>> getAvailableRoomSections({String? currentTenantId}) {
    final available = <MapEntry<String, String>>[];
    
    for (var room in _roomsList) {
      if (!room.isFull || (currentTenantId != null && room.sections.any((s) => s.tenantId == currentTenantId))) {
        final sections = room.getAvailableSections(currentTenantId: currentTenantId);
        for (var section in sections) {
          available.add(MapEntry(room.number, section));
        }
      }
    }

    return available;
  }

  bool isRoomNumberAvailable(String number) =>
      !_roomsList.any((room) => room.number == number);

  Room _getRoomById(String roomId) {
    return _roomsList.firstWhere(
      (room) => room.id == roomId,
      orElse: () => throw Exception('Room not found'),
    );
  }

  void _checkInitialization() {
    if (_rooms == null) {
      throw Exception('RoomProvider not initialized');
    }
  }

  @override
  void dispose() {
    _roomsSubscription?.cancel();
    _roomsList.clear();
    _tenantRoomCache.clear();
    _rooms = null;
    _userId = null;
    _isLoading = false;
    super.dispose();
  }
}
