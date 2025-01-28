import 'package:hive/hive.dart';

part 'tenant.g.dart';

@HiveType(typeId: 0)
class Tenant extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String roomNumber;

  @HiveField(3)
  double rentAmount;

  @HiveField(4)
  String paymentStatus;

  @HiveField(5)
  String phoneNumber;

  @HiveField(6)
  DateTime lastPaymentDate;

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
      rentAmount: map['rentAmount'].toDouble(),
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
