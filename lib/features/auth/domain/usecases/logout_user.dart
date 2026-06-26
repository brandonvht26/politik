import '../repositories/auth_repository.dart';

/// Clean Architecture use case that closes the active session.
class LogoutUser {
  final AuthRepository _repository;

  const LogoutUser(this._repository);

  Future<void> call() => _repository.logout();
}
