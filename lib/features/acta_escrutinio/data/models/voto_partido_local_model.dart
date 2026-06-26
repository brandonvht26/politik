import 'package:hive/hive.dart';

import '../../domain/entities/voto_partido_local_entity.dart';

part 'voto_partido_local_model.g.dart';

/// Hive model for a single party vote entry inside a local acta.
@HiveType(typeId: 3)
class VotoPartidoLocalModel extends VotoPartidoLocalEntity {
  @override
  @HiveField(0)
  String get nombreOrganizacion => super.nombreOrganizacion;

  @override
  @HiveField(1)
  int get cantidadVotos => super.cantidadVotos;

  const VotoPartidoLocalModel({
    required super.nombreOrganizacion,
    required super.cantidadVotos,
  });

  factory VotoPartidoLocalModel.fromEntity(VotoPartidoLocalEntity entity) {
    return VotoPartidoLocalModel(
      nombreOrganizacion: entity.nombreOrganizacion,
      cantidadVotos: entity.cantidadVotos,
    );
  }

  VotoPartidoLocalEntity toEntity() {
    return VotoPartidoLocalEntity(
      nombreOrganizacion: nombreOrganizacion,
      cantidadVotos: cantidadVotos,
    );
  }
}
