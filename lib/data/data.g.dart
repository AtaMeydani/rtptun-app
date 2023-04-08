// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VPNEntityAdapter extends TypeAdapter<VPNEntity> {
  @override
  final int typeId = 0;

  @override
  VPNEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VPNEntity()..vpnLocation = fields[0] as Location;
  }

  @override
  void write(BinaryWriter writer, VPNEntity obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.vpnLocation);
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

class LocationAdapter extends TypeAdapter<Location> {
  @override
  final int typeId = 2;

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
