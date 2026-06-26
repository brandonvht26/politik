import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correoReal;
  final String rol;
  final String? recintoId;
  final String? mesaId;

  const UserProfileEntity({
    required this.id,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correoReal,
    required this.rol,
    this.recintoId,
    this.mesaId,
  });

  String get nombreCompleto => '$nombres $apellidos';

  @override
  List<Object?> get props => [
        id,
        cedula,
        nombres,
        apellidos,
        telefono,
        correoReal,
        rol,
        recintoId,
        mesaId,
      ];
}
