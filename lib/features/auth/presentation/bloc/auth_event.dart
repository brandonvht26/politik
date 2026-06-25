import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

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
