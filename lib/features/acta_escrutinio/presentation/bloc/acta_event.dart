import 'package:equatable/equatable.dart';

import '../../domain/entities/voto_partido_local_entity.dart';

abstract class ActaEvent extends Equatable {
  const ActaEvent();

  @override
  List<Object?> get props => [];
}

/// Requests a camera capture and sharpness validation.
class CapturePhotoRequested extends ActaEvent {}

/// Requests GPS acquisition, vote validation and local persistence.
class SaveActaRequested extends ActaEvent {
  final String recintoId;
  final String mesaId;
  final String tipo;
  final List<VotoPartidoLocalEntity> votosPartidos;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;
  final String imageLocalPath;
  final String? imageId;
  final double? latitud;
  final double? longitud;

  const SaveActaRequested({
    required this.recintoId,
    required this.mesaId,
    required this.tipo,
    required this.votosPartidos,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
    required this.imageLocalPath,
    this.imageId,
    this.latitud,
    this.longitud,
  });

  @override
  List<Object?> get props => [
        recintoId,
        mesaId,
        tipo,
        votosPartidos,
        votosBlancos,
        votosNulos,
        totalSufragantes,
        imageLocalPath,
      ];
}
