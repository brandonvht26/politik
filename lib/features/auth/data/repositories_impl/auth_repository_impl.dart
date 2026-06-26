import 'package:appwrite/appwrite.dart';
import 'package:hive/hive.dart';

import '../../../../core/services/appwrite_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../data/models/session_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Appwrite-backed implementation of [AuthRepository].
///
/// Responsibilities:
/// - Maps the national ID to the virtual email `[cedula]@politik.com`.
/// - Authenticates against Appwrite Auth.
/// - Reads the user's role from the `profiles` collection.
/// - Persists the session in the Hive `session` box.
class AuthRepositoryImpl implements AuthRepository {
  final AppwriteService _appwrite;
  final Box<SessionModel> _sessionBox;

  UserEntity? _currentUser;
  SessionModel? _pendingSession;

  AuthRepositoryImpl({
    AppwriteService? appwriteService,
    Box<SessionModel>? sessionBox,
  })  : _appwrite = appwriteService ?? AppwriteService(),
        _sessionBox = sessionBox ?? LocalStorageService.sessionBox;

  @override
  Future<UserEntity> login({
    required String cedula,
    required String password,
  }) async {
    final email = '$cedula@politik.com';

    try {
      await _appwrite.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al iniciar sesión');
    }

    final profileList = await _appwrite.databases.listDocuments(
      databaseId: _appwrite.databaseId,
      collectionId: _appwrite.profilesCollectionId,
      queries: [Query.equal('cedula', cedula)],
    );

    if (profileList.documents.isEmpty) {
      throw Exception('No se encontró el perfil asociado a la cédula $cedula');
    }

    final profile = profileList.documents.first.data;
    final rol = profile['rol'] as String? ?? 'veedor';
    final recintoId = profile['recinto_id'] as String?;
    final mesaId = profile['mesa_id'] as String?;
    final nombres = profile['nombres'] as String? ?? '';
    final apellidos = profile['apellidos'] as String? ?? '';
    final telefono = profile['telefono'] as String? ?? '';

    final user = UserEntity(
      id: cedula,
      email: email,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      rol: rol,
      requiresPasswordChange: password == 'Ecuador2026',
    );

    _currentUser = user;
    _pendingSession = SessionModel(
      cedula: cedula,
      rol: rol,
      recintoId: recintoId,
      mesaId: mesaId,
    );

    // Only persist the session when the user has already changed the default
    // password. For first logins with the default password, the session is
    // saved after a successful password change.
    if (password != 'Ecuador2026') {
      await _sessionBox.put('current', _pendingSession!);
    }

    return user;
  }

  @override
  Future<UserEntity> changePassword({required String newPassword}) async {
    try {
      await _appwrite.account.updatePassword(password: newPassword);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cambiar la contraseña');
    }

    // Persist the session now that the default password has been changed.
    if (_pendingSession != null) {
      await _sessionBox.put('current', _pendingSession!);
      _pendingSession = null;
    } else if (_currentUser != null) {
      await _sessionBox.put(
        'current',
        SessionModel(
          cedula: _currentUser!.id,
          rol: _currentUser!.rol,
          recintoId: null,
          mesaId: null,
        ),
      );
    }

    if (_currentUser != null) {
      return _currentUser!;
    }

    final accountUser = await _appwrite.account.get();
    return UserEntity(
      id: accountUser.$id,
      email: accountUser.email,
      nombres: '',
      apellidos: '',
      telefono: '',
      rol: 'veedor',
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _appwrite.account.deleteSession(sessionId: 'current');
    } catch (_) {
      // Ignore failures when there is no active session.
    }

    await _sessionBox.delete('current');
    _currentUser = null;
    _pendingSession = null;
  }
}
