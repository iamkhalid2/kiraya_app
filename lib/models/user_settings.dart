class UserSettings {
  final int totalRooms;
  final bool enableNotifications;
  final bool enableDarkMode;
  final String currency;
  final Map<String, dynamic> additionalSettings;

  UserSettings({
    this.totalRooms = 10,
    this.enableNotifications = true,
    this.enableDarkMode = false,
    this.currency = '₹',
    this.additionalSettings = const {},
  });

  UserSettings copyWith({
    int? totalRooms,
    bool? enableNotifications,
    bool? enableDarkMode,
    String? currency,
    Map<String, dynamic>? additionalSettings,
  }) {
    return UserSettings(
      totalRooms: totalRooms ?? this.totalRooms,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableDarkMode: enableDarkMode ?? this.enableDarkMode,
      currency: currency ?? this.currency,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalRooms': totalRooms,
      'enableNotifications': enableNotifications,
      'enableDarkMode': enableDarkMode,
      'currency': currency,
      'additionalSettings': additionalSettings,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      totalRooms: map['totalRooms'] as int? ?? 10,
      enableNotifications: map['enableNotifications'] as bool? ?? true,
      enableDarkMode: map['enableDarkMode'] as bool? ?? false,
      currency: map['currency'] as String? ?? '₹',
      additionalSettings: map['additionalSettings'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  String toString() {
    return 'UserSettings(totalRooms: $totalRooms, enableNotifications: $enableNotifications, enableDarkMode: $enableDarkMode, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings &&
        other.totalRooms == totalRooms &&
        other.enableNotifications == enableNotifications &&
        other.enableDarkMode == enableDarkMode &&
        other.currency == currency;
  }

  @override
  int get hashCode {
    return totalRooms.hashCode ^
        enableNotifications.hashCode ^
        enableDarkMode.hashCode ^
        currency.hashCode;
  }
}
