import '../../../../core/utils/cedula_validator.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Clean Architecture use case that authenticates a user by cédula.
class LoginUser {
  final AuthRepository _repository;

  const LoginUser(this._repository);

  Future<UserEntity> call({
    required String cedula,
    required String password,
  }) async {
    // 1. Validación de Cédula Ecuatoriana (Módulo 10)
    final validation = CedulaValidator.validate(cedula);
    if (!validation.isValid) {
      throw Exception(validation.message ?? 'Cédula inválida');
    }

    // 2. Ejecutar login a través del repositorio
    return _repository.login(cedula: cedula, password: password);
  }
}
