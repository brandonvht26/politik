import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// Emitted after a successful login or password change.
class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Emitted when the user logged in with the default password `Ecuador2026`.
///
/// The UI must redirect to [ForcePasswordChangePage].
class AuthRequiresPasswordChange extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
