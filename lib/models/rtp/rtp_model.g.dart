// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rtp_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RTPAdapter extends TypeAdapter<RTP> {
  @override
  final int typeId = 2;

  @override
  RTP read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RTP(
      remark: fields[0] as String?,
      serverAddress: fields[1] as String?,
      serverPort: fields[2] as String?,
      localAddress: fields[3] as String?,
      localPort: fields[4] as String?,
      secretKey: fields[5] as String?,
      vpn: fields[6] as VPN?,
    );
  }

  @override
  void write(BinaryWriter writer, RTP obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.remark)
      ..writeByte(1)
      ..write(obj.serverAddress)
      ..writeByte(2)
      ..write(obj.serverPort)
      ..writeByte(3)
      ..write(obj.localAddress)
      ..writeByte(4)
      ..write(obj.localPort)
      ..writeByte(5)
      ..write(obj.secretKey)
      ..writeByte(6)
      ..write(obj.vpn);
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
