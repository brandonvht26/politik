import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Clean Architecture use case that authenticates a user by cédula.
class LoginUser {
  final AuthRepository _repository;

  const LoginUser(this._repository);

  Future<UserEntity> call({
    required String cedula,
    required String password,
  }) {
    return _repository.login(cedula: cedula, password: password);
  }
}
