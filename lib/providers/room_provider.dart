import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference? _rooms;
  List<Room> _roomsList = [];
  String? _userId;

  List<Room> get rooms => _roomsList;

  Stream<List<Room>> get roomsStream {
    if (_rooms == null) return Stream.value([]);

    return _rooms!.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Room.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList()
        ..sort((a, b) => a.number.compareTo(b.number));
    });
  }

  void initialize(String userId) {
    _userId = userId;
    _rooms = _firestore.collection('users/$userId/rooms');
    notifyListeners();
  }

  Future<void> addRoom(Room room) async {
    if (_rooms == null) throw Exception('RoomProvider not initialized');

    await _rooms!.add(room.toMap());
  }

  Future<void> updateRoom(Room room) async {
    if (_rooms == null) throw Exception('RoomProvider not initialized');
    if (room.id == null) throw Exception('Room ID is null');

    await _rooms!.doc(room.id).update(room.toMap());
  }

  Future<void> deleteRoom(String roomId) async {
    if (_rooms == null) throw Exception('RoomProvider not initialized');

    await _rooms!.doc(roomId).delete();
  }

  Future<void> assignTenant(String roomId, String sectionId, String tenantId) async {
    if (_rooms == null) throw Exception('RoomProvider not initialized');

    final room = _roomsList.firstWhere((room) => room.id == roomId);
    final section = room.getSection(sectionId);
    
    if (section.isOccupied) {
      throw Exception('Section is already occupied');
    }

    section.isOccupied = true;
    section.tenantId = tenantId;

    await updateRoom(room);
  }

  Future<void> removeTenant(String roomId, String sectionId) async {
    if (_rooms == null) throw Exception('RoomProvider not initialized');

    final room = _roomsList.firstWhere((room) => room.id == roomId);
    final section = room.getSection(sectionId);
    
    section.isOccupied = false;
    section.tenantId = null;

    await updateRoom(room);
  }

  List<MapEntry<String, String>> getAvailableRoomSections() {
    final available = <MapEntry<String, String>>[];
    
    for (var room in _roomsList) {
      if (!room.isFull()) {
        final sections = room.getAvailableSections();
        for (var section in sections) {
          available.add(MapEntry(room.number, section));
        }
      }
    }

    return available;
  }

  bool isRoomNumberAvailable(String number) {
    return !_roomsList.any((room) => room.number == number);
  }
}
