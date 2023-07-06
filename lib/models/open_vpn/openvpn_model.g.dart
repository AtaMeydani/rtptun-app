// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openvpn_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OpenVPNModelAdapter extends TypeAdapter<OpenVPNModel> {
  @override
  final int typeId = 4;

  @override
  OpenVPNModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OpenVPNModel(
      config: fields[0] as String?,
      username: fields[1] as String?,
      password: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OpenVPNModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.config)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenVPNModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
