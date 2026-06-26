import 'package:equatable/equatable.dart';

import '../../domain/entities/recinto_entity.dart';

abstract class ProvincialEvent extends Equatable {
  const ProvincialEvent();

  @override
  List<Object?> get props => [];
}

class LoadProvincialData extends ProvincialEvent {}

class CreateRecintoRequested extends ProvincialEvent {
  final RecintoEntity recinto;

  const CreateRecintoRequested(this.recinto);

  @override
  List<Object?> get props => [recinto];
}

class CreateCoordinadorRecintoRequested extends ProvincialEvent {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correoReal;
  final String recintoId;

  const CreateCoordinadorRecintoRequested({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correoReal,
    required this.recintoId,
  });

  @override
  List<Object?> get props =>
      [cedula, nombres, apellidos, telefono, correoReal, recintoId];
}
