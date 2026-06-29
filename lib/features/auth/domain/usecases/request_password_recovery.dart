import '../repositories/auth_repository.dart';

class RequestPasswordRecovery {
  final AuthRepository _repository;

  const RequestPasswordRecovery(this._repository);

  Future<void> call({required String cedula}) {
    return _repository.requestPasswordRecovery(cedula: cedula);
  }
}
