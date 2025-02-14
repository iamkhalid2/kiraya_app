import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/user_settings.dart';

class UserSettingsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  UserSettings _settings = UserSettings();
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  String? _userId;

  UserSettings get settings => _settings;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<DocumentSnapshot> get settingsStream => _firestoreService.userSettingsStream;

  void initialize(String? userId) {
    if (userId == null) {
      reset();
      return;
    }

    if (_userId == userId && _isInitialized) {
      return;
    }

    _userId = userId;
    _firestoreService.initialize(userId);
    _settings = UserSettings();
    _isInitialized = true;
    notifyListeners();
    
    _loadSettings();
  }

  void reset() {
    _settings = UserSettings();
    _isInitialized = true; // Mark as initialized even when resetting
    _userId = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    debugPrint('UserSettingsProvider: Loading settings...');
    _setLoading(true);
    try {
      final loadedSettings = await _firestoreService.getUserSettings();
      debugPrint('UserSettingsProvider: Settings loaded: $loadedSettings');
      _settings = loadedSettings;
      _error = null;
    } catch (e) {
      debugPrint('UserSettingsProvider: Error loading settings: $e');
      _error = e.toString();
      // Keep using default settings on error
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> updateTotalRooms(int newTotal, int currentRoomCount) async {
    if (!_isInitialized) {
      throw Exception('Settings provider not initialized');
    }

    if (newTotal < 1) {
      throw Exception('Room limit must be at least 1');
    }

    if (newTotal < currentRoomCount) {
      throw Exception(
        'Cannot reduce room limit below current room count ($currentRoomCount)'
      );
    }

    final newSettings = _settings.copyWith(totalRooms: newTotal);
    await updateSettings(newSettings);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    if (!_isInitialized) {
      throw Exception('Settings provider not initialized');
    }

    _setLoading(true);
    try {
      await _firestoreService.updateUserSettings(newSettings);
      _settings = newSettings;
      _setError(null);
    } catch (e) {
      debugPrint('Error updating settings: $e');
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetToDefault() async {
    if (!_isInitialized) {
      throw Exception('Settings provider not initialized');
    }

    _setLoading(true);
    try {
      final defaultSettings = UserSettings();
      await _firestoreService.updateUserSettings(defaultSettings);
      _settings = defaultSettings;
      _setError(null);
    } catch (e) {
      debugPrint('Error resetting settings: $e');
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cleanUp() async {
    try {
      await _firestoreService.deleteUserSettings();
      _settings = UserSettings();
      _isInitialized = false;
      _userId = null;
      _setError(null);
    } catch (e) {
      debugPrint('Error cleaning up settings: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    _settings = UserSettings();
    _userId = null;
    super.dispose();
  }
}
