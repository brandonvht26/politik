# Rules & Constitution

> **IMPORTANTE:** Este archivo actúa como la "Constitución" del directorio `.context`. Sus reglas mandan sobre cualquier otro archivo o directriz. **Solo puede modificarse con la autorización explícita del usuario. No puede eliminarse.**

## 1. Contexto del Proyecto y Reto Tecnológico
- **Temática:** Aplicación Móvil para Veeduría Electoral (Juntas Receptoras del Voto).
- **Objetivo Principal:** Permitir a los veedores electorales autenticarse de manera ágil en el recinto electoral y subir evidencia gráfica de las actas de escrutinio a los servidores.
- **Reto Tecnológico Crítico:** **Detección de imágenes borrosas en el cliente.** El sistema DEBE validar localmente (mediante algoritmos como varianza del Laplaciano en Flutter) que la fotografía del acta de escrutinio esté totalmente enfocada/nítida antes de permitir la subida, para asegurar que sirva como evidencia válida.
- **Estrategia de Defensa Académica:** Se ha elegido **Appwrite** sobre Supabase exclusivamente para asegurar la tolerancia a una alta concurrencia de peticiones durante la defensa final y evitar errores `429 Too Many Requests`.

## 2. Stack Tecnológico
- **Framework:** Flutter (Mobile)
- **Lenguaje:** Dart
- **Backend as a Service:** Appwrite (Autenticación, Base de Datos, Storage) - *Pausado temporalmente por rate limits*.
- **Almacenamiento Local (Offline-First):** Hive o Drift (Requerido para puntos extra).
- **State Management:** `flutter_bloc`
- **Autenticación Biométrica:** `local_auth` (Planeado a futuro)
- **Sensores Exigidos:** `geolocator` (GPS obligatorio), `image_picker` + `image_blur_detection` (Cámara).

## 3. Idioma
- **Desarrollo (Código):** Inglés. Variables, funciones, clases, comentarios en el código base deben estar en inglés (`UserRepository`, `loginUser`, `AuthBloc`).
- **Interfaz de Usuario (UI):** Español. Cualquier texto visible para el usuario final debe estar en español ("Iniciar Sesión", "Ingresa tu contraseña").

## 4. Guías de Estilo y Patrones
- **Arquitectura:** Clean Architecture + Vertical Slicing. (Revisar `architecture.md`).
- **Responsabilidad Única (SOLID):** Funciones y clases pequeñas y bien definidas.
- **Manejo de Estado (BLoC):** Todo proceso debe tener retroalimentación visual explícita (Loading, Success, Error). **ESTRICTAMENTE PROHIBIDO** dejar pantallas en blanco.
- **UI Responsiva y Fluida:** (Revisar `skills/ui/SKILL.md`).

## 5. Reglas de Negocio (Examen)
- **Login:** El usuario (username) SIEMPRE debe ser la Cédula de Identidad.
- **Roles:** Coordinador Provincial (crea recintos y coords. recinto) > Coordinador de Recinto (crea veedores y mesas) > Veedor de Mesa (ingresa actas).
- **Validaciones Críticas:** Los votos de los candidatos NO pueden sumar más que el total de sufragantes. La foto del acta NO puede ser borrosa. Todo registro requiere coordenadas GPS.
- **Modo Offline:** El flujo del Veedor debe ser completamente funcional sin internet (Persistencia Local) con sincronización en segundo plano (+15 pts extra).

## 6. Gestión del Directorio `.context`
- **`rules.md`**: Supremo. Solo actualizable con permiso.
- **`architecture.md`**: Fijo. No eliminable, no actualizable.
- **`roadmap.md`**: Volátil. Llenado solo bajo autorización al iniciar un Sprint/Fase grande.
- **`session.md`**: Volátil. Resumen de jornada. Actualizable, no eliminable.
- **`skills/`**: Directorio de habilidades y patrones específicos (ej. `ui/SKILL.md`).
