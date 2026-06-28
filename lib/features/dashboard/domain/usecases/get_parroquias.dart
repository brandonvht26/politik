import '../repositories/dashboard_repository.dart';

class GetParroquias {
  final DashboardRepository repository;

  GetParroquias(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getParroquias();
  }
}
