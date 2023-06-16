// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rtp_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RTPAdapter extends TypeAdapter<RTP> {
  @override
  final int typeId = 1;

  @override
  RTP read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RTP(
      remark: fields[0] as String,
      address: fields[1] as String,
      port: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RTP obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.remark)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.port);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RTPAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
