import '../repositories/dashboard_repository.dart';

class GetActas {
  final DashboardRepository repository;

  GetActas(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getActas();
  }
}
