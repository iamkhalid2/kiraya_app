import '../models/room.dart';

class DataValidator {
  static String? validateRoomNumber(String? value, List<Room> existingRooms) {
    if (value == null || value.isEmpty) return 'Room number required';
    if (existingRooms.any((r) => r.number == value)) {
      return 'Room number already exists';
    }
    return null;
  }

  static String? validateTenantDetails(String? value, String field) {
    if (value == null || value.isEmpty) return '$field is required';
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Phone number required';
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validateAmount(String? value, String field) {
    if (value == null || value.isEmpty) return '$field required';
    if (double.tryParse(value) == null) return 'Enter a valid amount';
    if (double.parse(value) <= 0) return '$field must be greater than 0';
    return null;
  }
}
