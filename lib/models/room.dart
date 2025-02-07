import 'package:cloud_firestore/cloud_firestore.dart';

class Section {
  final String id;  // A, B, C, D
  bool isOccupied;
  String? tenantId;

  Section({
    required this.id,
    this.isOccupied = false,
    this.tenantId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isOccupied': isOccupied,
      'tenantId': tenantId,
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'] as String,
      isOccupied: map['isOccupied'] as bool,
      tenantId: map['tenantId'] as String?,
    );
  }
}

class Room {
  String? id;
  String number;
  int occupantLimit;
  List<Section> sections;

  Room({
    this.id,
    required this.number,
    required this.occupantLimit,
    List<Section>? sections,
  }) : sections = sections ?? _createSections(occupantLimit);

  static List<Section> _createSections(int limit) {
    final sectionIds = ['A', 'B', 'C', 'D'];
    return List.generate(
      limit,
      (index) => Section(id: sectionIds[index]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'occupantLimit': occupantLimit,
      'sections': sections.map((section) => section.toMap()).toList(),
    };
  }

  factory Room.fromMap(String roomId, Map<String, dynamic> map) {
    return Room(
      id: roomId,
      number: map['number'] as String,
      occupantLimit: map['occupantLimit'] as int,
      sections: (map['sections'] as List<dynamic>)
          .map((section) => Section.fromMap(section as Map<String, dynamic>))
          .toList(),
    );
  }

  bool isFull() {
    return sections.every((section) => section.isOccupied);
  }

  List<String> getAvailableSections() {
    return sections
        .where((section) => !section.isOccupied)
        .map((section) => section.id)
        .toList();
  }

  bool hasSection(String sectionId) {
    return sections.any((section) => section.id == sectionId);
  }

  Section getSection(String sectionId) {
    return sections.firstWhere(
      (section) => section.id == sectionId,
      orElse: () => throw Exception('Section not found: $sectionId'),
    );
  }

  double getPaymentRatio() {
    if (sections.isEmpty) return 0.0;
    
    int occupied = sections.where((s) => s.isOccupied).length;
    if (occupied == 0) return 0.0;

    int paid = 0;
    for (var section in sections) {
      if (section.isOccupied && section.tenantId != null) {
        // This will need to be updated to check actual tenant payment status
        paid++;
      }
    }

    return paid / occupied;
  }
}
