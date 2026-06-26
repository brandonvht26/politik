import 'package:equatable/equatable.dart';

abstract class RecintoEvent extends Equatable {
  const RecintoEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecintoData extends RecintoEvent {
  final String recintoId;

  const LoadRecintoData(this.recintoId);

  @override
  List<Object?> get props => [recintoId];
}

class CreateVeedorRequested extends RecintoEvent {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correoReal;
  final String recintoId;
  final String mesaId;

  const CreateVeedorRequested({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correoReal,
    required this.recintoId,
    required this.mesaId,
  });

  @override
  List<Object?> get props =>
      [cedula, nombres, apellidos, telefono, correoReal, recintoId, mesaId];
}

class ReassignVeedorMesaRequested extends RecintoEvent {
  final String cedula;
  final String newMesaId;

  const ReassignVeedorMesaRequested({
    required this.cedula,
    required this.newMesaId,
  });

  @override
  List<Object?> get props => [cedula, newMesaId];
}
