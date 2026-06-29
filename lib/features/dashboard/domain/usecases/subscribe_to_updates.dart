import '../repositories/dashboard_repository.dart';

class SubscribeToUpdates {
  final DashboardRepository repository;

  SubscribeToUpdates(this.repository);

  Stream<dynamic> call() {
    return repository.subscribeToUpdates();
  }
}
