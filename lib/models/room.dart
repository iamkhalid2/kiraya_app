import 'package:cloud_firestore/cloud_firestore.dart';

enum RoomType {
  single(1),
  double(2),
  triple(3),
  quad(4);

  final int capacity;
  const RoomType(this.capacity);

  static RoomType fromCapacity(int capacity) {
    return RoomType.values.firstWhere(
      (type) => type.capacity == capacity,
      orElse: () => throw ArgumentError('Invalid capacity: $capacity'),
    );
  }
}

class Section {
  final String id;  // A, B, C, D
  bool isOccupied;
  String? tenantId;
  String? tenantName;  // Cache tenant name to reduce Firestore reads

  Section({
    required this.id,
    this.isOccupied = false,
    this.tenantId,
    this.tenantName,
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
  RoomType type;
  List<Section> sections;
  DateTime? lastUpdated;

  Room({
    this.id,
    required this.number,
    required int occupantLimit,
    List<Section>? sections,
    this.lastUpdated,
  }) : type = RoomType.fromCapacity(occupantLimit),
       sections = sections ?? _createSections(occupantLimit);

  static List<Section> _createSections(int limit) {
    const sectionIds = ['A', 'B', 'C', 'D'];
    return List.generate(
      limit,
      (index) => Section(id: sectionIds[index]),
    ).toList(growable: false);  // Fixed-length list for better performance
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'occupantLimit': type.capacity,
      'sections': sections.map((section) => section.toMap()).toList(),
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  factory Room.fromMap(String roomId, Map<String, dynamic> map) {
    final occupantLimit = map['occupantLimit'] as int;
    final timestamp = map['lastUpdated'] as Timestamp?;
    
    return Room(
      id: roomId,
      number: map['number'] as String,
      occupantLimit: occupantLimit,
      sections: (map['sections'] as List<dynamic>)
          .map((section) => Section.fromMap(section as Map<String, dynamic>))
          .toList(growable: false),  // Fixed-length list
      lastUpdated: timestamp?.toDate(),
    );
  }

  // Optimized helper methods
  bool get isFull => sections.every((section) => section.isOccupied);
  bool get isEmpty => sections.every((section) => !section.isOccupied);
  int get occupiedCount => sections.where((s) => s.isOccupied).length;
  int get occupantLimit => type.capacity;

  List<String> getAvailableSections({String? currentTenantId}) {
    return sections
        .where((section) => !section.isOccupied || section.tenantId == currentTenantId)
        .map((section) => section.id)
        .toList(growable: false);
  }

  bool hasSection(String sectionId) => 
      sections.indexWhere((section) => section.id == sectionId) != -1;

  Section getSection(String sectionId) {
    final index = sections.indexWhere((section) => section.id == sectionId);
    if (index == -1) throw Exception('Section not found: $sectionId');
    return sections[index];
  }

  // Updates section data efficiently
  void updateSection(String sectionId, {
    bool? isOccupied, 
    String? tenantId,
    String? tenantName,
  }) {
    final section = getSection(sectionId);
    if (isOccupied != null) section.isOccupied = isOccupied;
    section.tenantId = tenantId;
    section.tenantName = tenantName;
  }

  // Checks if a specific tenant can be assigned to this room
  bool canAcceptTenant(String? currentTenantId) =>
      !isFull || sections.any((s) => s.tenantId == currentTenantId);

  // Gets section occupancy status for UI display
  Map<String, bool> getSectionOccupancyMap() {
    return Map.fromEntries(
      sections.map((s) => MapEntry(s.id, s.isOccupied))
    );
  }
}
