import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String rol;
  final bool requiresPasswordChange;

  const UserEntity({
    required this.id,
    required this.email,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.rol,
    this.requiresPasswordChange = false,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        nombres,
        apellidos,
        telefono,
        rol,
        requiresPasswordChange,
      ];
}
