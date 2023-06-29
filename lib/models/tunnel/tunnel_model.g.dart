// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tunnel_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TunnelAdapter extends TypeAdapter<Tunnel> {
  @override
  final int typeId = 1;

  @override
  Tunnel read(BinaryReader reader) {
    return Tunnel();
  }

  @override
  void write(BinaryWriter writer, Tunnel obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TunnelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
