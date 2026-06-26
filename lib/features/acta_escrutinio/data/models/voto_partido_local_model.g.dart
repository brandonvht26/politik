// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voto_partido_local_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VotoPartidoLocalModelAdapter extends TypeAdapter<VotoPartidoLocalModel> {
  @override
  final int typeId = 3;

  @override
  VotoPartidoLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VotoPartidoLocalModel(
      nombreOrganizacion: fields[0] as String,
      cantidadVotos: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, VotoPartidoLocalModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nombreOrganizacion)
      ..writeByte(1)
      ..write(obj.cantidadVotos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VotoPartidoLocalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
