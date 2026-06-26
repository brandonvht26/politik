import '../entities/user_profile_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetVeedoresPorRecinto {
  final DashboardRepository _repository;

  const GetVeedoresPorRecinto(this._repository);

  Future<List<UserProfileEntity>> call(String recintoId) {
    return _repository.getVeedoresPorRecinto(recintoId);
  }
}
