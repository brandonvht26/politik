import '../repositories/dashboard_repository.dart';

class ReassignVeedorMesa {
  final DashboardRepository _repository;

  const ReassignVeedorMesa(this._repository);

  Future<void> call({
    required String cedula,
    required String newMesaId,
  }) {
    return _repository.reassignVeedorMesa(
      cedula: cedula,
      newMesaId: newMesaId,
    );
  }
}
