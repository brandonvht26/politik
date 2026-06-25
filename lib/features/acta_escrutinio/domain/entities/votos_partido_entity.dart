import 'package:equatable/equatable.dart';

class VotosPartidoEntity extends Equatable {
  final String idOrganizacion;
  final String nombreOrganizacion;
  final int cantidadVotos;

  const VotosPartidoEntity({
    required this.idOrganizacion,
    required this.nombreOrganizacion,
    required this.cantidadVotos,
  });

  @override
  List<Object?> get props => [idOrganizacion, nombreOrganizacion, cantidadVotos];
}
