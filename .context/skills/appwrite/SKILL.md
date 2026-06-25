---
name: appwrite_flutter_sdk
description: Referencia completa del SDK de Appwrite para Flutter. Cómo inicializar, autenticar, y las diferencias críticas con Supabase.
---

# Appwrite Flutter SDK — Guía de Referencia

## 1. Inicialización del Cliente

```dart
import 'package:appwrite/appwrite.dart';

// Crear el cliente (singleton, una sola vez en la app)
final client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1') // Appwrite Cloud endpoint
    .setProject('TU_PROJECT_ID')                  // Tu Project ID
    .setSelfSigned(status: false);                // false para Cloud, true para self-hosted con SSL propio

// El servicio Account se crea a partir del Client
final account = Account(client);
```

**Diferencia con Supabase:**
- Supabase: `Supabase.initialize(url: url, anonKey: anonKey)` → usa `Supabase.instance.client`
- Appwrite: `Client().setEndpoint().setProject()` → no usa `anonKey`, la autenticación es por sesión

## 2. Autenticación — Operaciones Principales

### Login (Email + Password)
```dart
// Supabase:
// final response = await supabase.auth.signInWithPassword(email: email, password: password);

// Appwrite:
final session = await account.createEmailPasswordSession(
  email: email,
  password: password,
);
// Retorna un objeto Session con: $id, userId, provider, expire, etc.
```

### Registro
```dart
// Supabase:
// final response = await supabase.auth.signUp(email: email, password: password);

// Appwrite:
final user = await account.create(
  userId: ID.unique(), // Appwrite genera un ID único
  email: email,
  password: password,
  name: displayName, // Opcional
);
// Retorna un objeto User con: $id, name, email, emailVerification, etc.
// NOTA: Después del registro, NO hay sesión activa automáticamente.
// Debes hacer login después: account.createEmailPasswordSession(...)
```

### Obtener Usuario Actual
```dart
// Supabase:
// final user = supabase.auth.currentUser;

// Appwrite:
try {
  final user = await account.get();
  // Si hay sesión activa, retorna el User
} on AppwriteException {
  // No hay sesión activa (usuario no autenticado)
}
// IMPORTANTE: Esto es async y puede fallar. No hay propiedad síncrona como en Supabase.
```

### Logout
```dart
// Supabase:
// await supabase.auth.signOut();

// Appwrite:
await account.deleteSession(sessionId: 'current');
// 'current' cierra solo la sesión activa. También existe account.deleteSessions() para todas.
```

### Verificación de Email
```dart
// Paso 1: Enviar email de verificación (desde la app Flutter)
await account.createVerification(
  url: 'https://tu-app.vercel.app/verify', // URL de callback
);
// Appwrite Cloud envía el email automáticamente (no necesita SMTP config)

// Paso 2: Confirmar verificación (desde la página web de callback)
// La página web recibe userId y secret como query params y llama:
await account.updateVerification(
  userId: userId,
  secret: secret,
);
```

### Recuperación de Contraseña
```dart
// Paso 1: Enviar email de recovery (desde la app Flutter)
await account.createRecovery(
  email: email,
  url: 'https://tu-app.vercel.app/reset-password', // URL de callback
);

// Paso 2: Confirmar nueva contraseña (desde la página web de callback)
await account.updateRecovery(
  userId: userId,
  secret: secret,
  password: newPassword,        // Nueva contraseña
);
```

## 3. Manejo de Errores

```dart
try {
  final session = await account.createEmailPasswordSession(
    email: email,
    password: password,
  );
} on AppwriteException catch (e) {
  // e.message → Descripción del error (ej. "Invalid credentials")
  // e.code → Código HTTP (ej. 401)
  // e.type → Tipo de error de Appwrite (ej. "user_invalid_credentials")
  
  switch (e.code) {
    case 401:
      // Credenciales inválidas
      break;
    case 409:
      // Usuario ya existe (en registro)
      break;
    case 429:
      // Rate limit alcanzado
      break;
  }
}
```

**Diferencia con Supabase:** Supabase usa `AuthException`, Appwrite usa `AppwriteException`.

## 4. Modelo de Usuario — Mapeo

```dart
// Appwrite User object tiene estas propiedades:
// user.$id           → String (ID único del usuario)
// user.name          → String (nombre del usuario)
// user.email         → String (email del usuario)
// user.emailVerification → bool (si el email está verificado)
// user.status        → bool (si la cuenta está activa)
// user.registration  → String (fecha de registro)

// En el UserModel del proyecto, mapear así:
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final bool emailVerified;

  // Desde Appwrite User:
  factory UserModel.fromAppwriteUser(User user) {
    return UserModel(
      id: user.$id,
      email: user.email,
      displayName: user.name.isEmpty ? null : user.name,
      emailVerified: user.emailVerification,
    );
  }
}
```

## 5. Auth State Changes (Diferencia Crítica)

**Supabase tiene:**
```dart
supabase.auth.onAuthStateChange.listen((data) {
  final event = data.event; // signedIn, signedOut, tokenRefreshed...
  final session = data.session;
});
```

**Appwrite NO tiene un stream equivalente.** Solución recomendada:

```dart
// Opción 1: Polling en el BLoC (recomendada para este proyecto)
Future<UserEntity?> checkAuthStatus() async {
  try {
    final user = await account.get();
    return UserModel.fromAppwriteUser(user).toEntity();
  } on AppwriteException {
    return null; // No hay sesión
  }
}

// Llamar esto al iniciar la app para decidir si mostrar login o home.
// En el main.dart: dispatch AuthCheckRequested al AuthBloc.
```

## 6. Paquete Dart — Versión e Import

```yaml
# pubspec.yaml
dependencies:
  appwrite: ^13.0.0
```

```dart
// Imports principales
import 'package:appwrite/appwrite.dart';     // Client, Account, ID, etc.
import 'package:appwrite/models.dart';        // User, Session, etc.
```

## 7. Configuración de Plataformas en la Consola de Appwrite

Para que la app Flutter se comunique con Appwrite Cloud, se deben registrar las plataformas:

| Plataforma | Valor a registrar |
|---|---|
| Flutter Android | Package name del `AndroidManifest.xml` (ej. `com.example.plantilla_prueba`) |
| Flutter iOS | Bundle ID del `Info.plist` |
| Web | Hostname sin protocolo (ej. `tu-app.vercel.app`) — requerido para callbacks |

**Si no registras la plataforma Web, los links de verificación/recovery serán rechazados por Appwrite.**
