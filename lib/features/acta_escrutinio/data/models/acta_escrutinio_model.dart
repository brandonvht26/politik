import 'package:hive/hive.dart';

import '../../domain/entities/acta_escrutinio_entity.dart';
import '../../domain/entities/votos_partido_entity.dart';
import 'votos_partido_model.dart';

part 'acta_escrutinio_model.g.dart';

@HiveType(typeId: 2)
class ActaEscrutinioModel extends ActaEscrutinioEntity {
  @override
  @HiveField(0)
  String get id => super.id;

  @override
  @HiveField(1)
  String get idJrv => super.idJrv;

  @override
  @HiveField(2)
  String get dignidad => super.dignidad;

  @override
  @HiveField(3)
  List<VotosPartidoEntity> get votosPorPartido => super.votosPorPartido;

  @override
  @HiveField(4)
  int get votosBlancos => super.votosBlancos;

  @override
  @HiveField(5)
  int get votosNulos => super.votosNulos;

  @override
  @HiveField(6)
  int get totalSufragantes => super.totalSufragantes;

  @override
  @HiveField(7)
  double? get latitud => super.latitud;

  @override
  @HiveField(8)
  double? get longitud => super.longitud;

  @override
  @HiveField(9)
  String get imagePath => super.imagePath;

  @override
  @HiveField(10)
  bool get isSynced => super.isSynced;

  const ActaEscrutinioModel({
    required super.id,
    required super.idJrv,
    required super.dignidad,
    required super.votosPorPartido,
    required super.votosBlancos,
    required super.votosNulos,
    required super.totalSufragantes,
    super.latitud,
    super.longitud,
    required super.imagePath,
    super.isSynced,
  });

  factory ActaEscrutinioModel.fromEntity(ActaEscrutinioEntity entity) {
    return ActaEscrutinioModel(
      id: entity.id,
      idJrv: entity.idJrv,
      dignidad: entity.dignidad,
      votosPorPartido: entity.votosPorPartido
          .map((v) => v is VotosPartidoModel
              ? v
              : VotosPartidoModel.fromEntity(v))
          .toList(),
      votosBlancos: entity.votosBlancos,
      votosNulos: entity.votosNulos,
      totalSufragantes: entity.totalSufragantes,
      latitud: entity.latitud,
      longitud: entity.longitud,
      imagePath: entity.imagePath,
      isSynced: entity.isSynced,
    );
  }

  ActaEscrutinioEntity toEntity() {
    return ActaEscrutinioEntity(
      id: id,
      idJrv: idJrv,
      dignidad: dignidad,
      votosPorPartido: votosPorPartido,
      votosBlancos: votosBlancos,
      votosNulos: votosNulos,
      totalSufragantes: totalSufragantes,
      latitud: latitud,
      longitud: longitud,
      imagePath: imagePath,
      isSynced: isSynced,
    );
  }
}
