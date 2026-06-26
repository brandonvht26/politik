import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Clean Architecture use case that updates the current user's password.
class ChangePassword {
  final AuthRepository _repository;

  const ChangePassword(this._repository);

  Future<UserEntity> call({required String newPassword}) {
    return _repository.changePassword(newPassword: newPassword);
  }
}
