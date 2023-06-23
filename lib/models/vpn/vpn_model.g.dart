// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vpn_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VPNAdapter extends TypeAdapter<VPN> {
  @override
  final int typeId = 1;

  @override
  VPN read(BinaryReader reader) {
    return VPN();
  }

  @override
  void write(BinaryWriter writer, VPN obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VPNAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
