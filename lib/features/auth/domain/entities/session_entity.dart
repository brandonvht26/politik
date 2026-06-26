import 'package:equatable/equatable.dart';

/// Minimal offline session kept in the `session` Hive box.
///
/// It allows the app to open the correct dashboard even without a network
/// connection after the first successful login.
class SessionEntity extends Equatable {
  /// National ID number used as the username.
  final String cedula;

  /// User role: `'provincial'`, `'recinto'` or `'veedor'`.
  final String rol;

  /// Polling place identifier when the role requires it.
  final String? recintoId;

  /// Assigned voting table when the role is `'veedor'`.
  final String? mesaId;

  const SessionEntity({
    required this.cedula,
    required this.rol,
    this.recintoId,
    this.mesaId,
  });

  @override
  List<Object?> get props => [cedula, rol, recintoId, mesaId];
}
