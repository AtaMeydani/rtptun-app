// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VPNEntityAdapter extends TypeAdapter<VPNEntity> {
  @override
  final int typeId = 1;

  @override
  VPNEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VPNEntity(
      remark: fields[0] as String,
      address: fields[1] as String,
      port: fields[2] as int,
      protocol: fields[3] as Protocol,
    );
  }

  @override
  void write(BinaryWriter writer, VPNEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.remark)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.port)
      ..writeByte(3)
      ..write(obj.protocol);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VPNEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProtocolAdapter extends TypeAdapter<Protocol> {
  @override
  final int typeId = 2;

  @override
  Protocol read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Protocol.rtp;
      default:
        return Protocol.rtp;
    }
  }

  @override
  void write(BinaryWriter writer, Protocol obj) {
    switch (obj) {
      case Protocol.rtp:
        writer.writeByte(0);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtocolAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationAdapter extends TypeAdapter<Location> {
  @override
  final int typeId = 3;

  @override
  Location read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Location.unknown;
      case 1:
        return Location.france;
      case 2:
        return Location.germany;
      case 3:
        return Location.us;
      case 4:
        return Location.uk;
      default:
        return Location.unknown;
    }
  }

  @override
  void write(BinaryWriter writer, Location obj) {
    switch (obj) {
      case Location.unknown:
        writer.writeByte(0);
        break;
      case Location.france:
        writer.writeByte(1);
        break;
      case Location.germany:
        writer.writeByte(2);
        break;
      case Location.us:
        writer.writeByte(3);
        break;
      case Location.uk:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
