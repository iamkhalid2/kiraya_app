import 'package:hive/hive.dart';

part 'complaint.g.dart';

@HiveType(typeId: 1)
class Complaint extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String status;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String tenantId;

  @HiveField(6)
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
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'tenantId': tenantId,
      'attachmentPath': attachmentPath,
    };
  }

  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      tenantId: map['tenantId'],
      createdAt: DateTime.parse(map['createdAt']),
      attachmentPath: map['attachmentPath'],
    );
  }

  Complaint copyWith({
    int? id,
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
