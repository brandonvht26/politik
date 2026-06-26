import '../entities/user_profile_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetCoordinadoresRecinto {
  final DashboardRepository _repository;

  const GetCoordinadoresRecinto(this._repository);

  Future<List<UserProfileEntity>> call() => _repository.getCoordinadoresRecinto();
}
