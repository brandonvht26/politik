# Roadmap

> **ATENCIÓN:** Archivo volátil. Solo se llena/actualiza cuando se ejecuta un plan grande y con **autorización explícita** del usuario. No puede eliminarse.

## Sprint Actual: Autenticación con Appwrite + Verificación/Recovery Web

**Autorizado por el usuario:** 2025-06-25
**Objetivo:** Implementar el feature `auth` completo usando Appwrite como BaaS, portando la arquitectura de `login_flutter_vercel` (Supabase) a Appwrite. Incluye páginas web de callback para verificación de email y reset de contraseña, desplegadas en Vercel.

---

### Fase 0: Configuración de Appwrite Cloud (PREVIO A CODIFICAR)
**Estado:** ⬜ Pendiente
**Modelo recomendado:** N/A — El usuario debe hacerlo manualmente desde la consola de Appwrite.

**Pasos:**
1. Crear cuenta en [Appwrite Cloud](https://cloud.appwrite.io) si no existe.
2. Crear un nuevo proyecto (ej. `veeduria-electoral`).
3. Anotar el **Project ID** y el **Endpoint** (`https://cloud.appwrite.io/v1`).
4. En la consola del proyecto, ir a **Auth > Settings**:
   - Habilitar el proveedor **Email/Password**.
   - En **Security**, verificar que la verificación de email esté habilitada.
5. En **Platforms**, añadir las plataformas:
   - `Flutter Android`: paquete `com.example.plantilla_prueba` (o el que corresponda).
   - `Flutter iOS`: bundle ID.
   - `Web`: hostname de Vercel (ej. `tu-proyecto.vercel.app`) — **esto es OBLIGATORIO** para que los links de verificación y recovery funcionen.
6. Guardar **Project ID** y **Endpoint** en el archivo `.env` del proyecto Flutter:
   ```
   APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
   APPWRITE_PROJECT_ID=tu-project-id-aqui
   ```

**Sobre los correos electrónicos en Appwrite Cloud:**
- Appwrite Cloud (plan gratuito) **envía correos automáticamente** para verificación de email y recovery de contraseña. NO necesitas configurar SMTP propio.
- Los correos salen desde los servidores de Appwrite con su dominio. No puedes personalizar el remitente en el plan free (necesitarías Pro para SMTP custom).
- **Esto es más sencillo que Supabase + Resend**, porque no hay que configurar nada externo. Appwrite se encarga de todo.
- Los correos llegarán a cualquier dirección de email, no hay la limitación de Resend free (que solo permite enviar a la cuenta registrada).
- Para la prueba académica, el plan free de Appwrite Cloud es más que suficiente.

---

### Fase 1: Core — Servicios y Utilidades Base
**Estado:** ⬜ Pendiente
**Modelo recomendado:** `DeepSeek V4 Flash` o `Qwen3.7 Plus` (tarea rutinaria, bien definida).

**Archivos a crear:**
- `lib/core/services/appwrite_client.dart` — Inicialización del Client + Account de Appwrite.
- `lib/core/errors/failures.dart` — Clases Failure para Either<Failure, T>.
- `lib/core/errors/exceptions.dart` — Excepciones personalizadas (ServerException, CacheException).
- `lib/core/usecase/usecase.dart` — Interfaz base UseCase<Type, Params>.
- `lib/core/constants/app_constants.dart` — Constantes (lectura de .env para Appwrite credentials).
- `lib/core/network/network_info.dart` — Verificación de conectividad.

**Dependencias a agregar en `pubspec.yaml`:**
```yaml
dependencies:
  appwrite: ^13.0.0
  flutter_bloc: ^9.1.0
  get_it: ^8.0.3
  injectable: ^2.5.0
  dartz: ^0.10.1
  equatable: ^2.0.7
  flutter_dotenv: ^5.2.1
  connectivity_plus: ^6.1.4
  image_picker: ^1.1.2          # Captura de fotos desde cámara
  image_blur_detection: ^1.0.1  # Detección de blur (Varianza del Laplaciano)

dev_dependencies:
  injectable_generator: ^2.6.3
  build_runner: ^2.4.14
```

**Archivo `.env.example` a llenar:**
```
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=tu-project-id
```

---

### Fase 2: Feature Auth — Capa de Dominio
**Estado:** ⬜ Pendiente
**Modelo recomendado:** `DeepSeek V4 Flash` (código directo, sin ambigüedad).

**Archivos a crear (estos NO dependen del backend, son idénticos al login_flutter_vercel):**
- `lib/features/auth/domain/entities/user_entity.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart` (interfaz abstracta)
- `lib/features/auth/domain/usecases/sign_in.dart`
- `lib/features/auth/domain/usecases/sign_up.dart`
- `lib/features/auth/domain/usecases/sign_out.dart`
- `lib/features/auth/domain/usecases/get_current_user.dart`
- `lib/features/auth/domain/usecases/reset_password.dart`

---

### Fase 3: Feature Auth — Capa de Datos (Appwrite)
**Estado:** ⬜ Pendiente
**Modelo recomendado:** `DeepSeek V4 Pro` o `Qwen3.7 Max` (requiere mapear APIs Supabase→Appwrite correctamente).

**Archivos a crear:**
- `lib/features/auth/data/models/user_model.dart` — Adaptado al modelo `User` de Appwrite (`$id`, `name`, `email`, `emailVerification`).
- `lib/features/auth/data/datasources/auth_remote_data_source.dart` — Implementación usando `Account` de Appwrite:
  - `signIn` → `account.createEmailPasswordSession(email, password)`
  - `signUp` → `account.create(userId: ID.unique(), email, password, name)` + `account.createVerification(url)`
  - `signOut` → `account.deleteSession(sessionId: 'current')`
  - `getCurrentUser` → `account.get()`
  - `resetPassword` → `account.createRecovery(email, url)`
  - **Nota:** Appwrite NO tiene un stream nativo de auth state changes. Usar polling con `account.get()` en try-catch.
- `lib/features/auth/data/repositories/auth_repository_impl.dart` — Misma estructura que login_flutter_vercel, usando dartz Either.

**Tabla de mapeo de APIs (referencia obligatoria):**
| Operación | Supabase (login_flutter_vercel) | Appwrite (plantilla_prueba) |
|---|---|---|
| Login | `supabase.auth.signInWithPassword(email, password)` | `account.createEmailPasswordSession(email: email, password: password)` |
| Registro | `supabase.auth.signUp(email, password)` | `account.create(userId: ID.unique(), email: email, password: password, name: name)` |
| Verificar email | Automático en Supabase | `account.createVerification(url: 'https://tu-app.vercel.app/verify')` |
| Logout | `supabase.auth.signOut()` | `account.deleteSession(sessionId: 'current')` |
| Usuario actual | `supabase.auth.currentUser` | `account.get()` |
| Reset password | `supabase.auth.resetPasswordForEmail(email)` | `account.createRecovery(email: email, url: 'https://tu-app.vercel.app/reset-password')` |
| Confirmar recovery | Automático en Supabase | `account.updateRecovery(userId, secret, password)` |
| Auth stream | `supabase.auth.onAuthStateChange` | No existe nativo. Usar polling con `account.get()` |

---

### Fase 4: Feature Auth — Inyección de Dependencias
**Estado:** ⬜ Pendiente
**Modelo recomendado:** `DeepSeek V4 Flash` (patrón bien conocido).

**Archivos a crear:**
- `lib/injection_container.dart` — Setup de GetIt + Injectable, registrando:
  - `Client` de Appwrite (singleton)
  - `Account` de Appwrite (singleton, derivado del Client)
  - `AuthRemoteDataSource` (lazySingleton)
  - `AuthRepository` (lazySingleton)
  - UseCases (factory)
  - `AuthBloc` (factory)
  - `Connectivity` (singleton)
  - `NetworkInfo` (lazySingleton)
- `lib/injection_container.config.dart` — Autogenerado por build_runner.

---

### Fase 5: Feature Auth — Capa de Presentación (BLoC + UI)
**Estado:** ⬜ Pendiente
**Modelo recomendado:** `DeepSeek V4 Pro` (UI compleja con lógica de estado).

**Archivos a crear:**
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/features/auth/presentation/bloc/auth_event.dart`
- `lib/features/auth/presentation/bloc/auth_state.dart`
- `lib/features/auth/presentation/pages/login_page.dart` — Adaptada con paleta CNE.
- `lib/features/auth/presentation/pages/register_page.dart`
- `lib/features/auth/presentation/pages/welcome_page.dart` — Home post-login.
- `lib/features/auth/presentation/pages/reset_password_page.dart`
- `lib/features/auth/presentation/pages/email_verification_sent_page.dart`
- `lib/features/auth/presentation/widgets/custom_text_field.dart`
- `lib/features/auth/presentation/widgets/loading_overlay.dart`
- Actualizar `lib/main.dart` con BlocProvider, routing, y detección de sesión activa.

---

### Fase 6: Páginas Web de Callback (Vercel)
**Estado:** ⬜ Pendiente
**Modelo recomendado:** `Qwen3.7 Plus` o `DeepSeek V4 Flash` (HTML/JS simple).

**Qué son y por qué las necesitamos:**
Cuando Appwrite envía un correo de verificación o recovery, incluye un link con `userId` y `secret` como query params. Ese link apunta a una URL que TÚ defines. Necesitamos páginas web que:
1. Reciban esos parámetros.
2. Llamen al API de Appwrite para confirmar la verificación o el cambio de contraseña.
3. Muestren un mensaje de éxito al usuario.

**Estructura del mini-proyecto web (en un directorio separado o en `web/` del proyecto):**
```
web-callbacks/
├── index.html          (landing o redirect)
├── verify.html         (recibe userId + secret, llama account.updateVerification)
├── reset-password.html (recibe userId + secret, muestra form de nueva contraseña, llama account.updateRecovery)
└── vercel.json         (configuración de rutas)
```

**Despliegue:**
1. Crear repo en GitHub (o un directorio en el mismo repo) con las páginas.
2. Conectar con Vercel.
3. Las URLs resultantes (ej. `https://veeduria-callbacks.vercel.app/verify.html`) se usan como parámetro `url` en `account.createVerification()` y `account.createRecovery()`.
4. **IMPORTANTE:** Agregar el hostname de Vercel como **plataforma Web** en la consola de Appwrite.

---

### Fase 7: Integración y Prueba End-to-End
**Estado:** ⬜ Pendiente
**Modelo recomendado:** `DeepSeek V4 Pro` (debugging complejo).

**Verificaciones:**
- [ ] `flutter analyze` limpio.
- [ ] `flutter build apk --debug` exitoso.
- [ ] Flujo completo: Registro → Email de verificación → Click en link → Verificado.
- [ ] Flujo completo: Olvidé contraseña → Email de recovery → Nueva contraseña.
- [ ] Login con cuenta verificada → Pantalla de bienvenida.
- [ ] Logout → Retorno a pantalla de login.
- [ ] Detección de sesión activa al abrir la app.

---

### Fase 8: Feature Acta Escrutinio — Captura + Validación de Blur
**Estado:** ⬜ Pendiente
**Modelo recomendado:** `DeepSeek V4 Pro` (lógica de validación + integración cámara + storage).

**Decisión técnica:** Se usará el paquete `image_blur_detection` (puro Dart, Varianza del Laplaciano). Decisión tomada por el desarrollador el 2025-06-25. Ver `defensa.md` para la justificación completa.

**Archivos a crear:**
- `lib/features/acta_escrutinio/data/datasources/acta_remote_data_source.dart` — Subida a Appwrite Storage.
- `lib/features/acta_escrutinio/data/models/acta_model.dart` — Modelo del acta (URL, timestamp, mesa, recinto).
- `lib/features/acta_escrutinio/data/repositories/acta_repository_impl.dart`
- `lib/features/acta_escrutinio/domain/entities/acta_entity.dart`
- `lib/features/acta_escrutinio/domain/repositories/acta_repository.dart`
- `lib/features/acta_escrutinio/domain/usecases/capture_acta.dart` — Orquesta: tomar foto → validar blur → subir.
- `lib/features/acta_escrutinio/domain/usecases/validate_image_quality.dart` — Usa `ImageQualityValidator`.
- `lib/features/acta_escrutinio/presentation/bloc/acta_bloc.dart`
- `lib/features/acta_escrutinio/presentation/bloc/acta_event.dart`
- `lib/features/acta_escrutinio/presentation/bloc/acta_state.dart`
- `lib/features/acta_escrutinio/presentation/pages/capture_acta_page.dart` — Pantalla con cámara + feedback visual.
- `lib/features/acta_escrutinio/presentation/widgets/quality_indicator.dart` — Badge visual ✅/❌.
- `lib/core/utils/image_quality_checker.dart` — Wrapper del paquete `image_blur_detection`.

**Flujo de la pantalla:**
1. Usuario presiona "Capturar Acta".
2. Se abre la cámara (`image_picker`).
3. Usuario toma la foto.
4. La app valida la imagen con `ImageQualityValidator`.
5. Si `result.isValid` → muestra preview con ✅ y botón "Subir".
6. Si `!result.isValid` → muestra preview con ❌ y mensaje "La foto es borrosa/oscura, toma otra".
7. Al subir → se guarda en Appwrite Storage + se registra metadata en Database.

**Dependencias (ya incluidas en Fase 1):**
```yaml
image_picker: ^1.1.2
image_blur_detection: ^1.0.1
```

**Código de referencia para el validador:**
```dart
// lib/core/utils/image_quality_checker.dart
import 'dart:typed_data';
import 'package:image_blur_detection/image_blur_detection.dart';

class ImageQualityChecker {
  final ImageQualityValidator _validator = ImageQualityValidator();

  Future<ImageQualityResult> check(Uint8List imageBytes) async {
    return await _validator.validate(imageBytes);
  }

  Future<bool> isAcceptable(Uint8List imageBytes) async {
    final result = await _validator.validate(imageBytes);
    return result.isValid;
  }
}
```

---

## Stack de Modelos de Inteligencia Artificial Disponibles
Para cada fase del roadmap, se debe asignar el modelo más apropiado de la siguiente lista de modelos disponibles:

- DeepSeek V4 Flash
- Kimi K2.6
- MiMo V2.5
- DeepSeek V4 Pro
- GLM-5.1
- Qwen3.7 Max
- Kimi K2.7 Code
- MiniMax M3 (3x usage)
- MiMo V2.5 Pro
- MiniMax M2.7
- Qwen3.7 Plus
- Qwen3.6 Plus
- GLM-5
- MiMo V2.5 Free
- North Mini Code Free
- Nemotron 3 Ultra Free
- DeepSeek V4 Flash Free
- Big Pickle

### Recomendaciones de Uso por Modelo:
- **Para Arquitectura Compleja y Algoritmos Pesados:** `DeepSeek V4 Pro` o `Qwen3.7 Max` (Por su alta capacidad de razonamiento en código y resolución de bugs profundos).
- **Para Generación Rápida de UI / Tareas Rutinarias / Refactorización simple:** `DeepSeek V4 Flash` o `Qwen3.7 Plus` (Rápidos y eficientes para tareas claras).
- **Para Scripts y Tooling específico:** `Kimi K2.7 Code`.
