import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
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
    // 1. Obtener el perfil de la base de datos para recuperar el correo_real
    // NOTA DE SEGURIDAD: Para que esto funcione antes de iniciar sesión, 
    // la colección 'profiles' en Appwrite DEBE tener permisos de read("any").
    late final DocumentList profileList;
    try {
      profileList = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.profilesCollectionId,
        queries: [Query.equal('cedula', cedula)],
      );
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        throw Exception('Permisos insuficientes. Configura read("any") en la colección profiles.');
      } else if (e.code == 400 && e.message?.contains('Index') == true) {
        throw Exception('Falta crear un índice tipo "key" para "cedula" en la colección profiles.');
      }
      throw Exception('Error al consultar perfil: ${e.message}');
    }

    if (profileList.documents.isEmpty) {
      throw Exception('No se encontró el perfil asociado a la cédula $cedula');
    }

    final profile = profileList.documents.first.data;
    final email = profile['correo_real'] as String? ?? '$cedula@politik.com';

    // 2. Iniciar sesión usando el correo real
    try {
      await _appwrite.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        throw Exception('Contraseña incorrecta. (Asegúrate de haber creado el usuario con la contraseña Ecuador2026)');
      }
      throw Exception('Error al iniciar sesión: ${e.message}');
    }

    final rol = profile['rol'] as String? ?? 'veedor';
    final recintoId = profile['recinto_id'] as String?;
    final mesaId = profile['mesa_id'] as String?;
    final nombres = profile['nombres'] as String? ?? '';
    final apellidos = profile['apellidos'] as String? ?? '';
    final telefono = profile['telefono'] as String? ?? '';

    final bool requiresPasswordChange = profile['requires_password_change'] as bool? ?? (password == 'Ecuador2026');

    final user = UserEntity(
      id: cedula,
      email: email,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      rol: rol,
      requiresPasswordChange: requiresPasswordChange,
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
      await _appwrite.account.updatePassword(
        password: newPassword,
        oldPassword: 'Ecuador2026', // Requerido por Appwrite por seguridad
      );

      // Actualizar el estado en la base de datos
      if (_currentUser != null) {
        final profileList = await _appwrite.databases.listDocuments(
          databaseId: _appwrite.databaseId,
          collectionId: _appwrite.profilesCollectionId,
          queries: [Query.equal('cedula', _currentUser!.id)],
        );

        if (profileList.documents.isNotEmpty) {
          final docId = profileList.documents.first.$id;
          await _appwrite.databases.updateDocument(
            databaseId: _appwrite.databaseId,
            collectionId: _appwrite.profilesCollectionId,
            documentId: docId,
            data: {'requires_password_change': false},
          );
        }
      }
    } on AppwriteException catch (e) {
      throw Exception('Error al cambiar la contraseña: ${e.message}');
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

  @override
  Future<void> requestPasswordRecovery({required String cedula}) async {
    try {
      final profileList = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.profilesCollectionId,
        queries: [Query.equal('cedula', cedula)],
      );

      if (profileList.documents.isEmpty) {
        throw Exception('No se encontró cuenta asociada a la cédula $cedula');
      }

      final profile = profileList.documents.first.data;
      final email = profile['correo_real'] as String?;

      if (email == null || email.isEmpty) {
        throw Exception('El usuario no tiene un correo electrónico configurado');
      }

      await _appwrite.account.createRecovery(
        email: email,
        // Usamos la raíz del sitio web con parámetro action=reset para evitar el error 404
        url: 'https://politik-app.netlify.app/?action=reset',
      );
    } on AppwriteException catch (e) {
      throw Exception('Error al solicitar recuperación: ${e.message}');
    }
  }

  @override
  Future<void> confirmPasswordRecovery({
    required String userId,
    required String secret,
    required String newPassword,
  }) async {
    try {
      await _appwrite.account.updateRecovery(
        userId: userId,
        secret: secret,
        password: newPassword,
      );
    } on AppwriteException catch (e) {
      throw Exception('Error al restablecer contraseña: ${e.message}');
    }
  }
}
