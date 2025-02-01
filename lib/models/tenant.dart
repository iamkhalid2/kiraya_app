import 'package:cloud_firestore/cloud_firestore.dart';

class Tenant {
  String? id; // Changed from int to String for Firestore document ID
  String name;
  String roomNumber;
  double rentAmount;
  String paymentStatus;
  String phoneNumber;
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
      'name': name,
      'roomNumber': roomNumber,
      'rentAmount': rentAmount,
      'paymentStatus': paymentStatus,
      'phoneNumber': phoneNumber,
      'lastPaymentDate': Timestamp.fromDate(lastPaymentDate),
    };
  }

  factory Tenant.fromMap(String id, Map<String, dynamic> map) {
    return Tenant(
      id: id,
      name: map['name'] as String,
      roomNumber: map['roomNumber'] as String,
      rentAmount: (map['rentAmount'] as num).toDouble(),
      paymentStatus: map['paymentStatus'] as String,
      phoneNumber: map['phoneNumber'] as String,
      lastPaymentDate: (map['lastPaymentDate'] as Timestamp).toDate(),
    );
  }

  Tenant copyWith({
    String? id,
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
