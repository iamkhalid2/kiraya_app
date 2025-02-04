class UserSettings {
  final int totalRooms;

  UserSettings({
    this.totalRooms = 20, // Default value
  });

  Map<String, dynamic> toMap() {
    return {
      'totalRooms': totalRooms,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      totalRooms: map['totalRooms'] ?? 20,
    );
  }

  UserSettings copyWith({
    int? totalRooms,
  }) {
    return UserSettings(
      totalRooms: totalRooms ?? this.totalRooms,
    );
  }
}
