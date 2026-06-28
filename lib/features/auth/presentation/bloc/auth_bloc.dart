import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../data/models/session_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser _loginUser;
  final ChangePassword _changePassword;
  final LogoutUser _logoutUser;

  AuthBloc({
    required LoginUser loginUser,
    required ChangePassword changePassword,
    required LogoutUser logoutUser,
  })  : _loginUser = loginUser,
        _changePassword = changePassword,
        _logoutUser = logoutUser,
        super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<LoginRequested>(_onLogin);
    on<ChangePasswordRequested>(_onChangePassword);
    on<LogoutRequested>(_onLogout);

    // Check whether a session was already persisted in Hive.
    add(AuthStarted());
  }

  Future<void> _onStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final session = LocalStorageService.sessionBox.get('current');
    if (session != null) {
      final user = _sessionToUser(session);
      emit(AuthSuccess(user));
      return;
    }

    emit(AuthInitial());
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {

    emit(AuthLoading());

    try {
      final user = await _loginUser(
        cedula: event.cedula.trim(),
        password: event.password,
      );

      if (event.password == 'Ecuador2026') {
        emit(AuthRequiresPasswordChange());
      } else {
        emit(AuthSuccess(user));
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

    try {
      final user = await _changePassword(newPassword: event.newPassword);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _logoutUser();
    } catch (_) {
      // Ignore logout failures; the UI will land back at the login screen.
    }

    emit(AuthInitial());
  }

  UserEntity _sessionToUser(SessionModel session) {
    return UserEntity(
      id: session.cedula,
      email: '${session.cedula}@politik.com',
      nombres: 'Usuario',
      apellidos: '',
      telefono: '',
      rol: session.rol,
      requiresPasswordChange: false,
    );
  }
}
