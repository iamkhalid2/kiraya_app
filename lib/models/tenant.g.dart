// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TenantAdapter extends TypeAdapter<Tenant> {
  @override
  final int typeId = 0;

  @override
  Tenant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tenant(
      id: fields[0] as int?,
      name: fields[1] as String,
      roomNumber: fields[2] as String,
      rentAmount: fields[3] as double,
      paymentStatus: fields[4] as String,
      phoneNumber: fields[5] as String,
      lastPaymentDate: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Tenant obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.roomNumber)
      ..writeByte(3)
      ..write(obj.rentAmount)
      ..writeByte(4)
      ..write(obj.paymentStatus)
      ..writeByte(5)
      ..write(obj.phoneNumber)
      ..writeByte(6)
      ..write(obj.lastPaymentDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TenantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
