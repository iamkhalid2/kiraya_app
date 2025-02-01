import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  String? id;
  String title;
  String description;
  String status;
  DateTime createdAt;
  String tenantId;
  String? attachmentPath;

  Complaint({
    this.id,
    required this.title,
    required this.description,
    this.status = 'Pending',
    required this.tenantId,
    DateTime? createdAt,
    this.attachmentPath,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'tenantId': tenantId,
      'attachmentPath': attachmentPath,
    };
  }

  factory Complaint.fromMap(String id, Map<String, dynamic> map) {
    return Complaint(
      id: id,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      tenantId: map['tenantId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      attachmentPath: map['attachmentPath'] as String?,
    );
  }

  Complaint copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? createdAt,
    String? tenantId,
    String? attachmentPath,
  }) {
    return Complaint(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      tenantId: tenantId ?? this.tenantId,
      attachmentPath: attachmentPath ?? this.attachmentPath,
    );
  }
}
