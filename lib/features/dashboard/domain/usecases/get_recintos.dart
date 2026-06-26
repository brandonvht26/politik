import '../entities/recinto_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetRecintos {
  final DashboardRepository _repository;

  const GetRecintos(this._repository);

  Future<List<RecintoEntity>> call() => _repository.getRecintos();
}
