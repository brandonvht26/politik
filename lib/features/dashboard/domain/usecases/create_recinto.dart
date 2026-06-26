import '../entities/recinto_entity.dart';
import '../repositories/dashboard_repository.dart';

class CreateRecinto {
  final DashboardRepository _repository;

  const CreateRecinto(this._repository);

  Future<void> call(RecintoEntity recinto) => _repository.createRecinto(recinto);
}
