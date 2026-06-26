# Guía de Defensa — Arquitectura y Decisiones Técnicas

> **Propósito:** Documento de estudio para la sustentación del proyecto *Politik*. Explica las decisiones arquitectónicas, la estrategia offline-first, la validación de imágenes borrosas y el dominio electoral que sustenta la aplicación.

---

## 1. ¿Por qué Clean Architecture + BLoC?

### 1.1 Desacoplamiento y mantenibilidad

La aplicación fue construida con **Clean Architecture** organizada en capas bien definidas:

```
UI (Pages / Widgets)
    ↑
Presentation (BLoC / States / Events)
    ↑
Domain (Entities / Use Cases / Repository Contracts)
    ↑
Data (Repositories Implementation / Data Sources / Models)
    ↑
External (Appwrite SDK, Hive, Geolocator, ImagePicker)
```

Esta división garantiza que:

- **El dominio no depende de frameworks.** Si mañana se cambia Appwrite por otro backend, solo se reescriben los repositorios de la capa de datos; las entidades, use cases y BLoC permanecen intactos.
- **Cada feature es un slice vertical.** `auth`, `dashboard`, `acta_escrutinio` tienen su propio domain, data y presentation. Esto permite trabajar módulos de forma independiente y escalar el equipo.
- **Las reglas de negocio están centralizadas.** Validaciones como `sumaVotos <= totalSufragantes` o la conversión de cédula a correo viven en use cases o repositorios, no dispersas en la UI.

### 1.2 BLoC como gestor de estado

Elegimos **BLoC (Business Logic Component)** porque:

| Beneficio | Cómo se aplica en Politik |
|---|---|
| **Estados explícitos** | `AuthLoading`, `AuthSuccess`, `AuthRequiresPasswordChange`, `ActaPhotoCaptured`, `ActaValidationError`, etc. Cada estado representa una situación concreta de la UI. |
| **Unidireccionalidad** | La UI emite eventos → el BLoC ejecuta lógica → emite un nuevo estado → la UI se reconstruye. No hay mutaciones directas desde widgets. |
| **Testabilidad** | Los BLoC se pueden unit-testear inyectando repositorios mock. La lógica de negocio no requiere renderizar widgets. |
| **Feedback visual obligatorio** | Al modelar estados de carga y error, se evita el "pantallazo en blanco". Siempre hay un `CircularProgressIndicator`, un `SnackBar` o un mensaje de error. |

### 1.3 Flujo típico

```
LoginPage → LoginRequested → AuthBloc → AuthRepository → Appwrite
                                      ↓
                              AuthSuccess / AuthError / AuthRequiresPasswordChange
```

La UI solo conoce eventos y estados; la implementación de Appwrite está oculta detrás del repositorio.

### 1.4 Anti-patrón de la pantalla en blanco: `AuthWrapper` + `CircularProgressIndicator`

Una de las reglas de oro del proyecto es **prohibir pantallas en blanco** durante cualquier transición de estado. Para garantizarlo, usamos un `AuthWrapper` como raíz de la app (`home: const AuthWrapper()` en `main.dart`). Este widget reacciona a cada estado del `AuthBloc`:

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is AuthRequiresPasswordChange) {
      return const ForcePasswordChangePage();
    }

    if (state is AuthSuccess) {
      final rol = state.user.rol;
      if (rol == 'provincial') return const ProvincialDashboardPage();
      if (rol == 'recinto') return const RecintoDashboardPage();
      return const MisMesasPage();
    }

    return const LoginPage();
  },
)
```

**Resultado:** Desde el arranque de la app hasta la navegación post-login, el usuario siempre ve:
- Un `CircularProgressIndicator` mientras se restaura la sesión desde Hive.
- La página de cambio de contraseña si aplica.
- El dashboard correcto según el rol.
- La pantalla de login si no hay sesión.

Este patrón se replica en cada feature: `LoginPage`, `ChangePasswordPage`, `ProvincialDashboardPage`, `RecintoDashboardPage` y `CameraPage` muestran un indicador de carga en sus estados intermedios. Nunca dejamos al usuario frente a una pantalla vacía sin retroalimentación.

---

## 2. ¿Por qué Appwrite sobre Supabase?

### 2.1 El problema: concurrencia en la defensa

Durante la sustentación, **múltiples equipos y veedores simulados** intentarán autenticarse, subir fotos y crear documentos al mismo tiempo. Esto genera un pico de peticiones concurrentes.

### 2.2 Límites de Supabase

Supabase (plan gratuito/Pro inicial) aplica **Rate Limits** estrictos por endpoint:

- Auth: ~10 req/s por IP.
- PostgREST: ~100 req/s por proyecto.
- Storage: ~100 req/s.

En una demo con 10–20 estudiantes presionando botones simultáneamente, es fácil recibir:

```
429 Too Many Requests
```

Eso congelaría la defensa, dejaría pantallas cargando y demostraría fragilidad ante el docente.

### 2.3 Ventajas de Appwrite para este escenario

| Aspecto | Appwrite Cloud | Supabase |
|---|---|---|
| Límite de solicitudes (gratuito) | **75,000 solicitudes/mes** con mayor tolerancia por burst | Más agresivo en throttling por endpoint |
| Arquitectura de servicios | Servicios separados (Auth, Database, Storage, Functions) | Todo pasa por PostgREST/Realtime |
| Permisos por recurso | Document Security y Bucket permissions granulares | RLS (Row Level Security) basado en políticas SQL |
| SDK Server para Flutter | `dart_appwrite` permite operaciones admin con API Key | Requiere Edge Functions o Service Role Key expuesta |

### 2.4 Decisión clave

Usamos **Appwrite** porque:

1. **Mayor tolerancia a picos de concurrencia** en un entorno de demo académico.
2. **Server SDK (`dart_appwrite`)** con API Key: permite crear usuarios jerárquicamente (Coordinador Provincial → Coordinador de Recinto → Veedor) sin exponer Service Role Key en el cliente de forma insegura.
3. **Document Security** facilita restringir que un veedor solo vea actas de su recinto.

> **Nota:** La API Key de Appwrite se mantiene en el archivo `.env` y debe configurarse con permisos mínimos (`users.write`, `buckets.files.write`, `databases.collections.documents.write`).

### 2.5 Escenario crítico: la defensa en vivo

Imagina la siguiente situación frente al docente: 10–20 estudiantes abren la app al mismo tiempo, presionan "Login", suben fotos de actas y crean documentos. Con Supabase gratuito, es probable que varios de esos usuarios reciban:

```
429 Too Many Requests
```

La pantalla se queda cargando, el docente ve la app fallar en vivo y la nota se resiente. Ese riesgo es inaceptable en una sustentación académica.

**Appwrite mitiga este riesgo** porque:
1. Los límites se manejan por proyecto completo con mayor tolerancia a picos (burst) en el plan gratuito.
2. Los servicios están separados: un pico en Storage no afecta Auth ni Database.
3. La latencia es predecible y la respuesta ante errores es controlada desde el BLoC con estados de error visibles.

> **Decisión de arquitectura:** Elegimos Appwrite no por moda, sino por **confiabilidad operacional** durante la demo. Un backend que se cae en vivo es un proyecto que no se defiende.

---

## 3. Sincronización Offline-First

### 3.1 Motivación

En un recinto electoral no siempre hay Wi-Fi estable. El veedor debe poder:

1. Tomar la foto del acta.
2. Ingresar los votos.
3. Guardar todo **localmente** sin depender de red.
4. Más tarde, cuando recupere conectividad, la app sube automáticamente la evidencia.

### 3.2 Arquitectura del guardado local

- Caja Hive: `actas_locales`.
- Modelo: `ActaEscrutinioLocalModel` con campos:
  - `uuid` — identificador temporal local.
  - `recintoId`, `mesaId`, `tipo` — contexto electoral.
  - `votosPartidos`, `votosBlancos`, `votosNulos`, `totalSufragantes` — resultados.
  - `latitud`, `longitud` — GPS.
  - `imageLocalPath` — ruta de la foto en el dispositivo.
  - `isSynced` — **false** al crear, **true** después de subir exitosamente.

```dart
final acta = ActaEscrutinioLocalEntity(
  uuid: '...',
  imageLocalPath: '/data/.../acta.jpg',
  isSynced: false,
  ...
);
```

### 3.3 Servicio de sincronización (`SyncService`)

El `SyncService` escucha dos fuentes:

1. **`connectivity_plus`** — detecta cuando hay Wi-Fi / datos móviles.
2. **`AuthBloc`** — solo sincroniza si hay un usuario autenticado (evita subir datos de sesiones cerradas).

```
Conexión + AuthSuccess → Sincronizar
Sin conexión → Esperar
Logout → Detener
```

### 3.4 Protocolo de sincronización por acta

Para cada acta con `isSynced == false`:

1. **Subir imagen** al Storage Bucket `actas_images`.
   ```dart
   final file = await storage.createFile(
     bucketId: bucketId,
     fileId: ID.unique(),
     file: InputFile.fromPath(path: acta.imageLocalPath),
   );
   ```
2. **Crear documento** en la colección `actas` incluyendo el `image_id` obtenido.
   ```dart
   await databases.createDocument(
     collectionId: actasCollectionId,
     data: { ..., 'image_id': file.$id },
   );
   ```
3. **Marcar local como sincronizado** solo si los pasos anteriores fueron exitosos.
   ```dart
   await actasBox.put(uuid, acta.copyWith(isSynced: true));
   ```

### 3.5 Manejo de conflictos y reputación (los 15 puntos extra)

La estrategia offline-first no es solo "guardar local y subir después". Para asegurar los **15 puntos extra** de la rúbrica, diseñamos un protocolo robusto:

1. **Identificador único por acta:** Cada acta local tiene un `uuid` generado en el dispositivo. Ese `uuid` es la clave de Hive y evita duplicados accidentales.
2. **Marcador atómico `isSynced`:** Solo se cambia a `true` cuando **ambas** operaciones remotas (Storage + Database) han terminado exitosamente. Si algo falla en el paso 2, el registro local permanece `false` y se reintenta en el próximo ciclo.
3. **Reintento por acta individual:** Si una acta falla, no se cancelan las demás. El bucle continúa con la siguiente, y la acta fallida se reintentará cuando haya conexión estable.
4. **No bloqueo de la UI:** El `SyncService` opera en background a través de streams (`connectivity_plus` + `AuthBloc`). El veedor puede seguir ingresando actas mientras otras se sincronizan.
5. **Resiliencia a cierres de app:** Como los datos viven en Hive, una app cerrada o un celular reiniciado no pierden las actas pendientes. Al volver a abrir con conexión, el sync se reactiva.

```
Acta guardada localmente (isSynced = false)
            ↓
Conexión detectada + usuario autenticado
            ↓
Subir imagen a Storage → obtener image_id
            ↓
Crear documento en Database con image_id
            ↓
Si ambos éxitos → isSynced = true
Si alguno falla → isSynced = false, reintentar luego
```

Este diseño no solo cumple el requerimiento offline; demuestra **pensamiento de arquitectura de software real**: tolerancia a fallos, idempotencia parcial y separación de responsabilidades.

### 3.6 Manejo de fallos

- Si la subida de una imagen falla, **se cancela solo esa acta** y se reintenta en el próximo ciclo.
- Si el documento no se crea, la imagen puede quedar huérfana en Storage, pero el registro local sigue `isSynced = false` para reintentar.
- El servicio nunca bloquea la UI; corre en background gracias a los streams.

---

## 4. Validación Local de Nitidez de Fotos y GPS

### 4.1 El reto tecnológico

Subir fotos borrosas al servidor desperdicia ancho de banda, almacenamiento y tiempo de procesamiento. Peor aún, **una foto borrosa no sirve como evidencia electoral**. Por eso validamos en el dispositivo **antes** de guardar o sincronizar.

### 4.2 Algoritmo: Varianza del Laplaciano

Utilizamos el paquete [`image_blur_detection`](https://pub.dev/packages/image_blur_detection), que implementa internamente el operador **Laplaciano** para medir la cantidad de bordes nítidos de una imagen.

#### Pasos del algoritmo

1. **Escala de grises** — Reduce la imagen a un solo canal para simplificar cálculos.
2. **Operador Laplaciano** — Filtro de detección de bordes. Resalta cambios bruscos de intensidad (texto, líneas, números).
3. **Varianza** — Mide cuán dispersos están esos valores de borde.
   - **Varianza ALTA** → muchos bordes definidos → imagen nítida ✅
   - **Varianza BAJA** → bordes difusos → imagen borrosa ❌
4. **Threshold** — El paquete compara la varianza contra un umbral configurado (`QualityConfig.photoCapture`).

```
Imagen nítida  → Varianza ALTA (ej. 350) → ✅ Aceptada
Imagen borrosa → Varianza BAJA (ej. 25)  → ❌ Rechazada
```

### 4.3 Implementación en la app

```dart
final validator = ImageQualityValidator(config: QualityConfig.photoCapture);
final result = await validator.validate(imageBytes);

if (!result.isValid) {
  throw Exception('La imagen está borrosa, por favor tómala de nuevo.');
}
```

El `ImageCaptureService` encapsula `image_picker` + `image_blur_detection` y es consumido por el `VeedorRepository` y el `ActaBloc`.

### 4.4 ¿Por qué este algoritmo para actas electorales?

Las actas contienen texto denso: nombres de candidatos, números de votos, firmas y sellos. El texto genera bordes muy definidos. Una foto borrosa pierde esos bordes y la varianza del Laplaciano cae drásticamente, haciendo del algoritmo una herramienta ideal para este caso de uso.

### 4.5 GPS infalible para el veedor con `geolocator`

La ubicación geográfica es evidencia clave: demuestra que el veedor estuvo físicamente en el recinto cuando fotografió el acta. Usamos `geolocator` porque ofrece:

- **Precisión configurable:** `LocationAccuracy.high` para coordenadas precisas.
- **Manejo robusto de permisos:** Detecta si el GPS está desactivado, si el permiso fue denegado o denegado permanentemente, y lanza excepciones claras para la UI.
- **Latitud y longitud confiables:** El `GpsService` encapsula toda la lógica y devuelve un `LocationEntity` puro que el `ActaBloc` consume sin dependencias de geolocator en la capa de presentación.

```dart
final position = await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.high,
  ),
);

return LocationEntity(
  latitude: position.latitude,
  longitude: position.longitude,
);
```

**¿Por qué es infalible para el veedor?**
- Si el GPS está apagado, la app informa inmediatamente y no deja guardar el acta sin coordenadas.
- Si el permiso es denegado, se muestra un mensaje claro que guía al usuario a ajustes.
- Si todo está correcto, se capturan las coordenadas exactas del recinto y se guardan en el modelo local, luego se sincronizan con Appwrite en el campo `latitud` / `longitud`.

Esto convierte al veedor en un testigo georreferenciado: no solo dice que estuvo en el recinto, sino que la app registra dónde exactamente tomó la foto.

---

## 5. Dominio del Problema — Contexto Electoral

### 5.1 ¿Qué es una Junta Receptora del Voto (JRV) / Mesa Electoral?

Es un **organismo electoral temporal** conformado por ciudadanos ecuatorianos designados por el CNE. Cada JRV opera en un recinto electoral el día de las elecciones.

#### Composición
- **Presidente/a** — Dirige la mesa.
- **Secretario/a** — Registra eventos en actas.
- **Vocales (1-3)** — Apoyan en funciones generales.

#### Funciones principales

| Fase | Qué hacen |
|---|---|
| **1. Instalación** | Reciben material electoral, verifican urnas vacías |
| **2. Votación** | Reciben electores, verifican identidad, entregan papeletas |
| **3. Escrutinio** | Cuentan votos y llenan las actas de escrutinio |
| **4. Embalaje** | Organizan el paquete electoral para el CNE |

### 5.2 ¿Qué es un Acta de Escrutinio?

Documento oficial donde la JRV registra los resultados del conteo de votos. Contiene:

- Votos por cada candidato/lista.
- Votos blancos y nulos.
- Firmas de los miembros de la mesa.
- Firmas de delegados de organizaciones políticas (opcional).

**¿Por qué fotografiarla?** Sirve como evidencia independiente. Si existen discrepancias con el reporte oficial del CNE, la foto es prueba. Por eso es crítico que no esté borrosa.

### 5.3 Veedor Electoral de Partido

- **Delegado de Organización Política:** Acreditado por el CNE para representar a un partido. Puede formular reclamos y solicitar copias de resultados.
- **Observador/Veedor Ciudadano:** Figura de control social que valida la transparencia general del proceso.

Nuestra app está orientada al **delegado de partido / veedor de mesa**, quien:

1. Se autentica.
2. Va a su JRV asignada.
3. Fotografía el acta después del escrutinio.
4. La app valida nitidez y guarda/sincroniza la evidencia.

---

## 6. Resumen del Flujo Completo

```
┌─────────────────────────────────────────────────────────────────────┐
│                            POLITIK                                  │
│                                                                     │
│  1. Login con cédula → mapeo a [cedula]@politik.com                │
│  2. Según el rol: Provincial / Recinto / Veedor                     │
│                                                                     │
│  PROVINCIAL              RECINTO                  VEEDOR            │
│  ├── Crear recintos      ├── Ver JRVs            ├── Mis Mesas      │
│  └── Crear coordinadores ├── Crear veedores      ├── Acta Alcalde   │
│                            └── Reasignar mesas    └── Acta Prefecto │
│                                                                     │
│  FLUJO DEL VEEDOR:                                                  │
│  1. Ingresa votos (5 orgs + blancos + nulos)                        │
│  2. Valida suma ≤ sufragantes                                       │
│  3. Toma foto → valida nitidez (Varianza del Laplaciano)            │
│  4. Captura GPS                                                     │
│  5. Guarda acta en Hive con isSynced = false                        │
│  6. Al recuperar red, SyncService sube foto + documento             │
│  7. Marca acta como isSynced = true                                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 7. Checklist para la Sustentación

- [ ] Explicar la división en capas de Clean Architecture.
- [ ] Mostrar cómo BLoC + `AuthWrapper` evitan pantallas en blanco (`AuthLoading`, `CircularProgressIndicator`).
- [ ] Justificar Appwrite vs Supabase por rate limits y confiabilidad en vivo.
- [ ] Demostrar el guardado offline en Hive con `isSynced = false` y sincronización posterior con `SyncService`.
- [ ] Explicar cómo `connectivity_plus` y `AuthBloc` disparan el Background Sync sin bloquear la UI.
- [ ] Explicar la Varianza del Laplaciano y por qué rechaza fotos borrosas antes de subir al Storage.
- [ ] Mostrar la captura GPS con `geolocator` y su rol como evidencia georreferenciada.
- [ ] Mostrar la validación de cédula con Módulo 10.
- [ ] Demostrar la creación jerárquica de usuarios (Provincial → Recinto → Veedor) con `dart_appwrite`.

---

## 8. Frases de Cierre para la Defensa (30 segundos cada una)

> **Sobre arquitectura:** "Nuestra app no depende de Appwrite; depende de contratos de repositorio. Si el docente pide cambiar el backend mañana, solo tocamos la capa de datos."

> **Sobre UX:** "No existe la pantalla en blanco. Desde el arranque, `AuthWrapper` muestra un `CircularProgressIndicator` mientras restaura la sesión de Hive y luego redirige al rol correcto."

> **Sobre Appwrite:** "Elegimos Appwrite porque en la defensa habrá picos de concurrencia. Supabase gratuito nos podría devolver `429 Too Many Requests` en vivo; Appwrite es más tolerante y nos da Server SDK con API Key."

> **Sobre offline-first:** "El veedor guarda el acta localmente con `isSynced = false`. Cuando recupera red y está autenticado, `SyncService` sube la imagen, crea el documento y solo entonces marca `isSynced = true`. Nada se pierde si se cierra la app."

> **Sobre sensores:** "Rechazamos fotos borrosas en el dispositivo con Varianza del Laplaciano antes de gastar ancho de banda, y capturamos GPS con `geolocator` para georreferenciar al veedor en el recinto."

---

## 9. Dependencias Clave

```yaml
dependencies:
  flutter_bloc: ^8.1.6
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  appwrite: ^12.0.0
  dart_appwrite: ^12.0.0
  geolocator: ^13.0.2
  image_picker: ^1.1.2
  image_blur_detection: ^1.0.1
  connectivity_plus: ^6.0.3

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.13
```

---

> **Documento preparado por:** OpenCode (Kimi k2.7-code)  
> **Fecha:** 2026-06-26  
> **Proyecto:** Politik — Veeduría Electoral Offline-First con Appwrite
