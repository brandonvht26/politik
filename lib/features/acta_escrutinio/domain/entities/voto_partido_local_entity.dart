import 'package:equatable/equatable.dart';

/// Votes obtained by a single political organization in a local acta.
class VotoPartidoLocalEntity extends Equatable {
  final String nombreOrganizacion;
  final int cantidadVotos;

  const VotoPartidoLocalEntity({
    required this.nombreOrganizacion,
    required this.cantidadVotos,
  });

  @override
  List<Object?> get props => [nombreOrganizacion, cantidadVotos];
}
