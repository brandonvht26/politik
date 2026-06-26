import '../entities/recinto_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetRecinto {
  final DashboardRepository _repository;

  const GetRecinto(this._repository);

  Future<RecintoEntity> call(String recintoId) => _repository.getRecinto(recintoId);
}
