import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<ChangePasswordRequested>(_onChangePassword);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));

    try {
      if (event.password == 'Ecuador2026') {
        emit(AuthRequirePasswordChange());
      } else {
        final user = UserEntity(
          id: event.cedula,
          email: '${event.cedula}@politik.com',
          nombres: 'Usuario',
          apellidos: 'Veedor',
          telefono: '0999999999',
          rol: 'veedor',
          requiresPasswordChange: false,
        );
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = UserEntity(
        id: '1234567890',
        email: '1234567890@politik.com',
        nombres: 'Usuario',
        apellidos: 'Veedor',
        telefono: '0999999999',
        rol: 'veedor',
        requiresPasswordChange: false,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUnauthenticated());
  }
}
