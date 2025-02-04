import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/user_settings.dart';

class UserSettingsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  UserSettings? _settings;
  bool _isLoading = false;

  UserSettings get settings => _settings ?? UserSettings();
  bool get isLoading => _isLoading;

  // Initialize settings stream
  UserSettingsProvider() {
    _firestoreService.userSettingsStream.listen((snapshot) {
      if (snapshot?.exists == true) {
        final data = snapshot?.data() as Map<String, dynamic>?;
        if (data != null) {
          _settings = UserSettings.fromMap(data);
          notifyListeners();
        }
      } else {
        _settings = UserSettings(); // Use default settings if no data
        notifyListeners();
      }
    });
  }

  // Update total rooms
  Future<void> updateTotalRooms(int totalRooms) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newSettings = settings.copyWith(totalRooms: totalRooms);
      await _firestoreService.updateUserSettings(newSettings);
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load initial settings
  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      notifyListeners();

      _settings = await _firestoreService.getUserSettings();
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
