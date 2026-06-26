import '../repositories/dashboard_repository.dart';

class CreateVeedor {
  final DashboardRepository _repository;

  const CreateVeedor(this._repository);

  Future<void> call({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correoReal,
    required String recintoId,
    required String mesaId,
  }) {
    return _repository.createVeedor(
      cedula: cedula,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      correoReal: correoReal,
      recintoId: recintoId,
      mesaId: mesaId,
    );
  }
}
