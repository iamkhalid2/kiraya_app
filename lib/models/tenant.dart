class Tenant {
  final int? id;
  final String name;
  final String roomNumber;
  final double rentAmount;
  final String paymentStatus;
  final String phoneNumber;
  final DateTime lastPaymentDate;

  Tenant({
    this.id,
    required this.name,
    required this.roomNumber,
    required this.rentAmount,
    required this.paymentStatus,
    required this.phoneNumber,
    required this.lastPaymentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roomNumber': roomNumber,
      'rentAmount': rentAmount,
      'paymentStatus': paymentStatus,
      'phoneNumber': phoneNumber,
      'lastPaymentDate': lastPaymentDate.toIso8601String(),
    };
  }

  factory Tenant.fromMap(Map<String, dynamic> map) {
    return Tenant(
      id: map['id'],
      name: map['name'],
      roomNumber: map['roomNumber'],
      rentAmount: map['rentAmount'],
      paymentStatus: map['paymentStatus'],
      phoneNumber: map['phoneNumber'],
      lastPaymentDate: DateTime.parse(map['lastPaymentDate']),
    );
  }

  Tenant copyWith({
    int? id,
    String? name,
    String? roomNumber,
    double? rentAmount,
    String? paymentStatus,
    String? phoneNumber,
    DateTime? lastPaymentDate,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      roomNumber: roomNumber ?? this.roomNumber,
      rentAmount: rentAmount ?? this.rentAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
    );
  }
}
