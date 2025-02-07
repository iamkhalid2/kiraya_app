import 'package:cloud_firestore/cloud_firestore.dart';

class Tenant {
  String? id; // Changed from int to String for Firestore document ID
  String name;
  String roomId;
  String section;  // A, B, C, D
  double rentAmount;
  double initialDeposit;
  String paymentStatus;
  String phoneNumber;
  DateTime joiningDate;
  DateTime nextDueDate;
  String? kycImage1;  // Will store image path/url later
  String? kycImage2;  // Will store image path/url later

  // For displaying room number in UI
  String get roomNumber => roomId;

  Tenant({
    this.id,
    required this.name,
    required this.roomId,
    required this.section,
    required this.rentAmount,
    required this.initialDeposit,
    required this.paymentStatus,
    required this.phoneNumber,
    required this.joiningDate,
    required this.nextDueDate,
    this.kycImage1,
    this.kycImage2,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'roomId': roomId,
      'section': section,
      'rentAmount': rentAmount,
      'paymentStatus': paymentStatus,
      'phoneNumber': phoneNumber,
      'initialDeposit': initialDeposit,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'kycImage1': kycImage1,
      'kycImage2': kycImage2,
    };
  }

  factory Tenant.fromMap(String id, Map<String, dynamic> map) {
    return Tenant(
      id: id,
      name: map['name'] as String,
      roomId: map['roomId'] as String,
      section: map['section'] as String,
      rentAmount: (map['rentAmount'] as num).toDouble(),
      paymentStatus: map['paymentStatus'] as String,
      phoneNumber: map['phoneNumber'] as String,
      initialDeposit: (map['initialDeposit'] as num).toDouble(),
      joiningDate: (map['joiningDate'] as Timestamp).toDate(),
      nextDueDate: (map['nextDueDate'] as Timestamp).toDate(),
      kycImage1: map['kycImage1'] as String?,
      kycImage2: map['kycImage2'] as String?,
    );
  }

  Tenant copyWith({
    String? id,
    String? name,
    String? roomId,
    String? section,
    double? rentAmount,
    String? paymentStatus,
    String? phoneNumber,
    double? initialDeposit,
    DateTime? joiningDate,
    DateTime? nextDueDate,
    String? kycImage1,
    String? kycImage2,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      roomId: roomId ?? this.roomId,
      section: section ?? this.section,
      rentAmount: rentAmount ?? this.rentAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      initialDeposit: initialDeposit ?? this.initialDeposit,
      joiningDate: joiningDate ?? this.joiningDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      kycImage1: kycImage1 ?? this.kycImage1,
      kycImage2: kycImage2 ?? this.kycImage2,
    );
  }
}
