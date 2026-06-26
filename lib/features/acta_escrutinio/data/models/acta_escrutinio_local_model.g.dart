// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acta_escrutinio_local_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActaEscrutinioLocalModelAdapter
    extends TypeAdapter<ActaEscrutinioLocalModel> {
  @override
  final int typeId = 4;

  @override
  ActaEscrutinioLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActaEscrutinioLocalModel(
      uuid: fields[0] as String,
      recintoId: fields[1] as String,
      mesaId: fields[2] as String,
      tipo: fields[3] as String,
      votosPartidos: (fields[4] as List).cast<VotoPartidoLocalEntity>(),
      votosBlancos: fields[5] as int,
      votosNulos: fields[6] as int,
      totalSufragantes: fields[7] as int,
      latitud: fields[8] as double,
      longitud: fields[9] as double,
      imageLocalPath: fields[10] as String,
      imageId: fields[11] as String?,
      isSynced: fields[12] as bool,
      createdAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ActaEscrutinioLocalModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.recintoId)
      ..writeByte(2)
      ..write(obj.mesaId)
      ..writeByte(3)
      ..write(obj.tipo)
      ..writeByte(4)
      ..write(obj.votosPartidos)
      ..writeByte(5)
      ..write(obj.votosBlancos)
      ..writeByte(6)
      ..write(obj.votosNulos)
      ..writeByte(7)
      ..write(obj.totalSufragantes)
      ..writeByte(8)
      ..write(obj.latitud)
      ..writeByte(9)
      ..write(obj.longitud)
      ..writeByte(10)
      ..write(obj.imageLocalPath)
      ..writeByte(11)
      ..write(obj.imageId)
      ..writeByte(12)
      ..write(obj.isSynced)
      ..writeByte(13)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActaEscrutinioLocalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
