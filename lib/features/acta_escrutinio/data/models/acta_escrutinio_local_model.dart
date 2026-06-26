import 'package:hive/hive.dart';

import '../../domain/entities/acta_escrutinio_local_entity.dart';
import '../../domain/entities/voto_partido_local_entity.dart';
import 'voto_partido_local_model.dart';

part 'acta_escrutinio_local_model.g.dart';

/// Hive model for the `actas_locales` box.
///
/// It extends the pure domain entity so the business object can be stored
/// directly while keeping a separation between domain and data layers.
@HiveType(typeId: 4)
class ActaEscrutinioLocalModel extends ActaEscrutinioLocalEntity {
  @override
  @HiveField(0)
  String get uuid => super.uuid;

  @override
  @HiveField(1)
  String get recintoId => super.recintoId;

  @override
  @HiveField(2)
  String get mesaId => super.mesaId;

  @override
  @HiveField(3)
  String get tipo => super.tipo;

  @override
  @HiveField(4)
  List<VotoPartidoLocalEntity> get votosPartidos => super.votosPartidos;

  @override
  @HiveField(5)
  int get votosBlancos => super.votosBlancos;

  @override
  @HiveField(6)
  int get votosNulos => super.votosNulos;

  @override
  @HiveField(7)
  int get totalSufragantes => super.totalSufragantes;

  @override
  @HiveField(8)
  double get latitud => super.latitud;

  @override
  @HiveField(9)
  double get longitud => super.longitud;

  @override
  @HiveField(10)
  String get imageLocalPath => super.imageLocalPath;

  @override
  @HiveField(11)
  String? get imageId => super.imageId;

  @override
  @HiveField(12)
  bool get isSynced => super.isSynced;

  @override
  @HiveField(13)
  DateTime get createdAt => super.createdAt;

  const ActaEscrutinioLocalModel({
    required super.uuid,
    required super.recintoId,
    required super.mesaId,
    required super.tipo,
    required super.votosPartidos,
    required super.votosBlancos,
    required super.votosNulos,
    required super.totalSufragantes,
    required super.latitud,
    required super.longitud,
    required super.imageLocalPath,
    super.imageId,
    super.isSynced,
    required super.createdAt,
  });

  factory ActaEscrutinioLocalModel.fromEntity(
    ActaEscrutinioLocalEntity entity,
  ) {
    return ActaEscrutinioLocalModel(
      uuid: entity.uuid,
      recintoId: entity.recintoId,
      mesaId: entity.mesaId,
      tipo: entity.tipo,
      votosPartidos: entity.votosPartidos
          .map(
            (v) => v is VotoPartidoLocalModel
                ? v
                : VotoPartidoLocalModel.fromEntity(v),
          )
          .toList(),
      votosBlancos: entity.votosBlancos,
      votosNulos: entity.votosNulos,
      totalSufragantes: entity.totalSufragantes,
      latitud: entity.latitud,
      longitud: entity.longitud,
      imageLocalPath: entity.imageLocalPath,
      imageId: entity.imageId,
      isSynced: entity.isSynced,
      createdAt: entity.createdAt,
    );
  }

  ActaEscrutinioLocalEntity toEntity() {
    return ActaEscrutinioLocalEntity(
      uuid: uuid,
      recintoId: recintoId,
      mesaId: mesaId,
      tipo: tipo,
      votosPartidos: votosPartidos
          .map((v) => (v as VotoPartidoLocalModel).toEntity())
          .toList(),
      votosBlancos: votosBlancos,
      votosNulos: votosNulos,
      totalSufragantes: totalSufragantes,
      latitud: latitud,
      longitud: longitud,
      imageLocalPath: imageLocalPath,
      imageId: imageId,
      isSynced: isSynced,
      createdAt: createdAt,
    );
  }
}
