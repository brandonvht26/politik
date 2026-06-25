import 'package:hive/hive.dart';

import '../../domain/entities/votos_partido_entity.dart';

part 'votos_partido_model.g.dart';

@HiveType(typeId: 1)
class VotosPartidoModel extends VotosPartidoEntity {
  @override
  @HiveField(0)
  String get idOrganizacion => super.idOrganizacion;

  @override
  @HiveField(1)
  String get nombreOrganizacion => super.nombreOrganizacion;

  @override
  @HiveField(2)
  int get cantidadVotos => super.cantidadVotos;

  const VotosPartidoModel({
    required super.idOrganizacion,
    required super.nombreOrganizacion,
    required super.cantidadVotos,
  });

  factory VotosPartidoModel.fromEntity(VotosPartidoEntity entity) {
    return VotosPartidoModel(
      idOrganizacion: entity.idOrganizacion,
      nombreOrganizacion: entity.nombreOrganizacion,
      cantidadVotos: entity.cantidadVotos,
    );
  }

  VotosPartidoEntity toEntity() {
    return VotosPartidoEntity(
      idOrganizacion: idOrganizacion,
      nombreOrganizacion: nombreOrganizacion,
      cantidadVotos: cantidadVotos,
    );
  }
}
