import '../entities/recinto_entity.dart';
import '../entities/user_profile_entity.dart';

/// Repository contract for the Provincial and Recinto dashboards.
///
/// It handles reading/writing `recintos` and `profiles` in Appwrite, plus
/// Appwrite Auth account creation for hierarchically created users.
abstract class DashboardRepository {
  Future<List<RecintoEntity>> getRecintos();

  Future<RecintoEntity> getRecinto(String recintoId);

  Future<void> createRecinto(RecintoEntity recinto);

  Future<List<UserProfileEntity>> getCoordinadoresRecinto();

  Future<List<UserProfileEntity>> getVeedoresPorRecinto(String recintoId);

  Future<List<Map<String, dynamic>>> getActas();

  Future<List<Map<String, dynamic>>> getOrganizacionesPoliticas();

  Future<List<Map<String, dynamic>>> getParroquias();

  Future<void> createCoordinadorRecinto({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correoReal,
    required String recintoId,
  });

  Future<void> createVeedor({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correoReal,
    required String recintoId,
    required String mesaId,
  });

  Future<void> reassignVeedorMesa({
    required String cedula,
    required String newMesaId,
  });
}
