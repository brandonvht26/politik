import '../repositories/auth_repository.dart';

class ConfirmPasswordRecovery {
  final AuthRepository _repository;

  const ConfirmPasswordRecovery(this._repository);

  Future<void> call({
    required String userId,
    required String secret,
    required String newPassword,
  }) {
    return _repository.confirmPasswordRecovery(
      userId: userId,
      secret: secret,
      newPassword: newPassword,
    );
  }
}
