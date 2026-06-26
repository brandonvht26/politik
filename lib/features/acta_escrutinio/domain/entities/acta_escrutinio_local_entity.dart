import 'package:equatable/equatable.dart';

import 'voto_partido_local_entity.dart';

/// Pure domain entity that represents an acta de escrutinio stored locally
/// while the device is offline.
///
/// This entity follows the structure defined in `database.md` for the
/// `actas_locales` Hive box.
class ActaEscrutinioLocalEntity extends Equatable {
  final String uuid;
  final String recintoId;
  final String mesaId;

  /// Election type: `'alcalde'` or `'prefecto'`.
  final String tipo;

  /// Votes per political organization/party.
  final List<VotoPartidoLocalEntity> votosPartidos;

  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;

  /// GPS coordinates captured when the acta was registered.
  final double latitud;
  final double longitud;

  /// Local filesystem path of the captured acta photo.
  final String imageLocalPath;

  /// Appwrite Storage image id assigned after a successful sync.
  final String? imageId;

  /// `false` when created locally; set to `true` after Appwrite sync.
  final bool isSynced;

  /// Moment when the local record was created.
  final DateTime createdAt;

  const ActaEscrutinioLocalEntity({
    required this.uuid,
    required this.recintoId,
    required this.mesaId,
    required this.tipo,
    required this.votosPartidos,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
    required this.latitud,
    required this.longitud,
    required this.imageLocalPath,
    this.imageId,
    this.isSynced = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        uuid,
        recintoId,
        mesaId,
        tipo,
        votosPartidos,
        votosBlancos,
        votosNulos,
        totalSufragantes,
        latitud,
        longitud,
        imageLocalPath,
        imageId,
        isSynced,
        createdAt,
      ];
}
