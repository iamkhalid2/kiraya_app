// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComplaintAdapter extends TypeAdapter<Complaint> {
  @override
  final int typeId = 1;

  @override
  Complaint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Complaint(
      id: fields[0] as int?,
      title: fields[1] as String,
      description: fields[2] as String,
      status: fields[3] as String,
      tenantId: fields[5] as String,
      createdAt: fields[4] as DateTime?,
      attachmentPath: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Complaint obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.tenantId)
      ..writeByte(6)
      ..write(obj.attachmentPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
