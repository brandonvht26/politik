---
name: auth_migration_guide
description: Guía técnica paso a paso para migrar el feature auth de login_flutter_vercel (Supabase) a plantilla_prueba (Appwrite). Incluye código de referencia para cada archivo.
---

# Guía de Migración Auth: Supabase → Appwrite

## Contexto
El proyecto `login_flutter_vercel` (GitHub: brandonvht26/login_flutter_vercel) implementa un sistema de autenticación completo con:
- Clean Architecture (data/domain/presentation)
- BLoC para state management
- GetIt + Injectable para DI
- Supabase como backend

Este skill documenta cómo portar cada archivo a Appwrite, indicando qué cambia y qué se mantiene.

---

## Archivos que se copian IDÉNTICOS (no dependen del backend)

### `lib/core/usecase/usecase.dart`
```dart
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
```

### `lib/core/errors/failures.dart`
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
```

### `lib/core/network/network_info.dart`
```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
```

### `lib/features/auth/domain/entities/user_entity.dart`
```dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final bool emailVerified;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.emailVerified = false,
  });

  @override
  List<Object?> get props => [id, email, displayName, emailVerified];
}
```

### `lib/features/auth/domain/repositories/auth_repository.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
```

### UseCases (todos idénticos, ejemplo sign_in):
```dart
// lib/features/auth/domain/usecases/sign_in.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignIn implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;
  SignIn(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) {
    return repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}
```

### BLoC (idéntico, ya que solo consume UseCases):
- `auth_event.dart`, `auth_state.dart`, `auth_bloc.dart` — Se copian tal cual del login_flutter_vercel.

---

## Archivos que CAMBIAN (dependen del backend)

### `lib/core/services/appwrite_client.dart` (NUEVO — reemplaza la init de Supabase)
```dart
import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteService {
  static late Client _client;
  static late Account _account;

  static Client get client => _client;
  static Account get account => _account;

  static void init() {
    _client = Client()
        .setEndpoint(dotenv.env['APPWRITE_ENDPOINT']!)
        .setProject(dotenv.env['APPWRITE_PROJECT_ID']!)
        .setSelfSigned(status: false);

    _account = Account(_client);
  }
}
```

### `lib/core/constants/app_constants.dart`
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get appwriteEndpoint => dotenv.env['APPWRITE_ENDPOINT']!;
  static String get appwriteProjectId => dotenv.env['APPWRITE_PROJECT_ID']!;
  
  // URLs de callback para verificación y recovery (página web en Vercel)
  static const String verificationCallbackUrl = 'https://TU-APP.vercel.app/verify';
  static const String recoveryCallbackUrl = 'https://TU-APP.vercel.app/reset-password';
}
```

### `lib/features/auth/data/models/user_model.dart` (CAMBIA mapeo)
```dart
import 'package:appwrite/models.dart' as appwrite;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.emailVerified,
  });

  /// Mapea desde el modelo User de Appwrite
  factory UserModel.fromAppwriteUser(appwrite.User user) {
    return UserModel(
      id: user.$id,
      email: user.email,
      displayName: user.name.isEmpty ? null : user.name,
      emailVerified: user.emailVerification,
    );
  }
}
```

### `lib/features/auth/data/datasources/auth_remote_data_source.dart` (CAMBIA implementación)
```dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Account account;
  AuthRemoteDataSourceImpl(this.account);

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Crear sesión (equivalente a supabase.auth.signInWithPassword)
    await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
    // Obtener datos del usuario autenticado
    final user = await account.get();
    return UserModel.fromAppwriteUser(user);
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Crear usuario (equivalente a supabase.auth.signUp)
    await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: displayName,
    );
    // Crear sesión para el usuario recién registrado
    await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
    // Enviar email de verificación
    await account.createVerification(
      url: AppConstants.verificationCallbackUrl,
    );
    final user = await account.get();
    return UserModel.fromAppwriteUser(user);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await account.createRecovery(
      email: email,
      url: AppConstants.recoveryCallbackUrl,
    );
  }

  @override
  Future<void> signOut() async {
    await account.deleteSession(sessionId: 'current');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = await account.get();
      return UserModel.fromAppwriteUser(user);
    } on AppwriteException {
      return null; // No hay sesión activa
    }
  }
}
```

### `lib/features/auth/data/repositories/auth_repository_impl.dart` (CAMBIA manejo de errores)
```dart
// Misma estructura, pero cambiar SupabaseException por AppwriteException:
// catch (e) { ... }
// En el login_flutter_vercel usa AuthException de Supabase.
// Aquí usar AppwriteException de Appwrite:
//   e.message → String con el mensaje
//   e.code → int con el código HTTP
```

### `lib/injection_container.dart` (CAMBIA registros de Appwrite)
```dart
// En lugar de registrar SupabaseClient:
//   sl.registerLazySingleton(() => Supabase.instance.client);

// Registrar Account de Appwrite:
import 'core/services/appwrite_client.dart';

// En la función configureDependencies:
getIt.registerLazySingleton<Account>(() => AppwriteService.account);
getIt.registerLazySingleton<Connectivity>(() => Connectivity());
// El resto (NetworkInfo, DataSource, Repository, UseCases, Bloc) se auto-registran con @injectable
```

### `lib/main.dart` (CAMBIA inicialización)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  // En lugar de Supabase.initialize():
  AppwriteService.init();
  
  await configureDependencies();
  runApp(const MyApp());
}
```

---

## Páginas Web de Callback (Vercel)

### `verify.html` — Verificación de Email
```html
<!DOCTYPE html>
<html>
<head><title>Verificación de Email</title></head>
<body>
  <h1>Verificando tu email...</h1>
  <p id="status">Procesando...</p>
  <script src="https://cdn.jsdelivr.net/npm/appwrite@16.0.0"></script>
  <script>
    const params = new URLSearchParams(window.location.search);
    const userId = params.get('userId');
    const secret = params.get('secret');

    const client = new Appwrite.Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('TU_PROJECT_ID');
    const account = new Appwrite.Account(client);

    account.updateVerification(userId, secret)
      .then(() => {
        document.getElementById('status').textContent = '✅ Email verificado correctamente. Puedes volver a la app.';
      })
      .catch(err => {
        document.getElementById('status').textContent = '❌ Error: ' + err.message;
      });
  </script>
</body>
</html>
```

### `reset-password.html` — Recuperación de Contraseña
```html
<!DOCTYPE html>
<html>
<head><title>Restablecer Contraseña</title></head>
<body>
  <h1>Nueva Contraseña</h1>
  <form id="resetForm">
    <input type="password" id="password" placeholder="Nueva contraseña" required minlength="8">
    <button type="submit">Cambiar contraseña</button>
  </form>
  <p id="status"></p>
  <script src="https://cdn.jsdelivr.net/npm/appwrite@16.0.0"></script>
  <script>
    const params = new URLSearchParams(window.location.search);
    const userId = params.get('userId');
    const secret = params.get('secret');

    const client = new Appwrite.Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('TU_PROJECT_ID');
    const account = new Appwrite.Account(client);

    document.getElementById('resetForm').addEventListener('submit', (e) => {
      e.preventDefault();
      const password = document.getElementById('password').value;
      account.updateRecovery(userId, secret, password)
        .then(() => {
          document.getElementById('status').textContent = '✅ Contraseña actualizada. Vuelve a la app e inicia sesión.';
        })
        .catch(err => {
          document.getElementById('status').textContent = '❌ Error: ' + err.message;
        });
    });
  </script>
</body>
</html>
```

---

## Checklist de Verificación Post-Migración
- [ ] `flutter analyze` sin errores.
- [ ] `flutter build apk --debug` exitoso.
- [ ] `.env` contiene `APPWRITE_ENDPOINT` y `APPWRITE_PROJECT_ID` reales.
- [ ] Plataforma Web registrada en consola Appwrite con hostname de Vercel.
- [ ] Plataforma Android registrada con package name correcto.
- [ ] Registro → se recibe email de verificación.
- [ ] Click en link de verificación → página web confirma → `emailVerification = true`.
- [ ] Login con cuenta verificada → sesión activa → pantalla home.
- [ ] Olvidé contraseña → email de recovery → nueva contraseña → login exitoso.
- [ ] Logout → sesión destruida → pantalla login.
- [ ] Al reabrir app con sesión activa → va directo a home (no login).
