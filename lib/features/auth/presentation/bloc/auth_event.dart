import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the app starts to check for a cached session.
class AuthStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String cedula;
  final String password;

  const LoginRequested({required this.cedula, required this.password});

  @override
  List<Object?> get props => [cedula, password];
}

class ChangePasswordRequested extends AuthEvent {
  final String newPassword;

  const ChangePasswordRequested({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}

class LogoutRequested extends AuthEvent {}

class PasswordRecoveryRequested extends AuthEvent {
  final String cedula;

  const PasswordRecoveryRequested({required this.cedula});

  @override
  List<Object?> get props => [cedula];
}

class PasswordResetConfirmed extends AuthEvent {
  final String userId;
  final String secret;
  final String newPassword;

  const PasswordResetConfirmed({
    required this.userId,
    required this.secret,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [userId, secret, newPassword];
}
