import '../entities/acta_escrutinio_local_entity.dart';
import '../repositories/veedor_repository.dart';

class SaveActaLocal {
  final VeedorRepository _repository;

  const SaveActaLocal(this._repository);

  Future<void> call(ActaEscrutinioLocalEntity acta) {
    return _repository.saveActaLocal(acta);
  }
}
