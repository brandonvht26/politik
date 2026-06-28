import '../repositories/dashboard_repository.dart';

class GetOrganizacionesPoliticas {
  final DashboardRepository repository;

  GetOrganizacionesPoliticas(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getOrganizacionesPoliticas();
  }
}
