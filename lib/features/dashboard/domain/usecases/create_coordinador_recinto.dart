import '../repositories/dashboard_repository.dart';

class CreateCoordinadorRecinto {
  final DashboardRepository _repository;

  const CreateCoordinadorRecinto(this._repository);

  Future<void> call({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correoReal,
    required String recintoId,
  }) {
    return _repository.createCoordinadorRecinto(
      cedula: cedula,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      correoReal: correoReal,
      recintoId: recintoId,
    );
  }
}
