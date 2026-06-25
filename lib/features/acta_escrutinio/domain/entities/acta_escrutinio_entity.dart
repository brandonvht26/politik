import 'package:equatable/equatable.dart';

import 'votos_partido_entity.dart';

class ActaEscrutinioEntity extends Equatable {
  final String id;
  final String idJrv;
  final String dignidad;
  final List<VotosPartidoEntity> votosPorPartido;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;
  final double? latitud;
  final double? longitud;
  final String imagePath;
  final bool isSynced;

  const ActaEscrutinioEntity({
    required this.id,
    required this.idJrv,
    required this.dignidad,
    required this.votosPorPartido,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
    this.latitud,
    this.longitud,
    required this.imagePath,
    this.isSynced = false,
  });

  @override
  List<Object?> get props => [
        id,
        idJrv,
        dignidad,
        votosPorPartido,
        votosBlancos,
        votosNulos,
        totalSufragantes,
        latitud,
        longitud,
        imagePath,
        isSynced,
      ];
}
