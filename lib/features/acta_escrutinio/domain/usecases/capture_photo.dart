import '../repositories/veedor_repository.dart';

class CapturePhoto {
  final VeedorRepository _repository;

  const CapturePhoto(this._repository);

  Future<String> call() => _repository.captureAndValidatePhoto();
}
