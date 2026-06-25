// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acta_escrutinio_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActaEscrutinioModelAdapter extends TypeAdapter<ActaEscrutinioModel> {
  @override
  final int typeId = 2;

  @override
  ActaEscrutinioModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActaEscrutinioModel(
      id: fields[0] as String,
      idJrv: fields[1] as String,
      dignidad: fields[2] as String,
      votosPorPartido: (fields[3] as List).cast<VotosPartidoEntity>(),
      votosBlancos: fields[4] as int,
      votosNulos: fields[5] as int,
      totalSufragantes: fields[6] as int,
      latitud: fields[7] as double?,
      longitud: fields[8] as double?,
      imagePath: fields[9] as String,
      isSynced: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ActaEscrutinioModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idJrv)
      ..writeByte(2)
      ..write(obj.dignidad)
      ..writeByte(3)
      ..write(obj.votosPorPartido)
      ..writeByte(4)
      ..write(obj.votosBlancos)
      ..writeByte(5)
      ..write(obj.votosNulos)
      ..writeByte(6)
      ..write(obj.totalSufragantes)
      ..writeByte(7)
      ..write(obj.latitud)
      ..writeByte(8)
      ..write(obj.longitud)
      ..writeByte(9)
      ..write(obj.imagePath)
      ..writeByte(10)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActaEscrutinioModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
