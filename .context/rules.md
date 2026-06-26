# Rules & Constitution

> **IMPORTANTE:** Este archivo actúa como la "Constitución" del directorio `.context`. Sus reglas mandan sobre cualquier otro archivo o directriz. **Solo puede modificarse con la autorización explícita del usuario. No puede eliminarse.**

## 1. Contexto del Proyecto y Reto Tecnológico
- **Temática:** Aplicación Móvil para Veeduría Electoral (Juntas Receptoras del Voto).
- **Objetivo Principal:** Permitir a los veedores electorales autenticarse de manera ágil en el recinto electoral y subir evidencia gráfica de las actas de escrutinio a los servidores, y a los coordinadores gestionar usuarios y métricas.
- **Reto Tecnológico Crítico:** **Detección de imágenes borrosas en el cliente.** El sistema DEBE validar localmente (mediante algoritmos como varianza del Laplaciano en Flutter) que la fotografía del acta de escrutinio esté totalmente enfocada/nítida antes de permitir la subida.
- **Estrategia de Defensa Académica:** Se ha elegido **Appwrite** para asegurar la tolerancia a concurrencia. Además, se implementará un modo **Offline-First (Hive)** para garantizar 15 puntos extra y robustez ante fallos de red durante la sustentación.

## 2. Stack Tecnológico
- **Framework:** Flutter (Mobile)
- **Lenguaje:** Dart
- **Backend as a Service:** Appwrite (Autenticación, Base de Datos, Storage).
- **Almacenamiento Local (Offline-First):** Hive.
- **State Management:** `flutter_bloc`.
- **Sensores Exigidos:** `geolocator` (GPS obligatorio), `image_picker` + `image_blur_detection` (Cámara).

## 3. Idioma
- **Desarrollo (Código):** Inglés (`UserRepository`, `loginUser`, `AuthBloc`).
- **Interfaz de Usuario (UI):** Español ("Iniciar Sesión", "Ingresa tu contraseña").

## 4. Guías de Estilo y Patrones
- **Arquitectura:** Clean Architecture + Vertical Slicing. (Revisar `architecture.md`).
- **Responsabilidad Única (SOLID):** Funciones y clases pequeñas y bien definidas.
- **Manejo de Estado (BLoC):** Todo proceso debe tener retroalimentación visual explícita (Loading, Success, Error). **ESTRICTAMENTE PROHIBIDO** dejar pantallas en blanco.
- **UI Responsiva y Fluida:** (Revisar `skills/ui/SKILL.md`).

## 5. Reglas de Negocio Estrictas (Rúbrica Examen)
- **Autenticación (Login):** El login en la UI requiere estrictamente la **Cédula de Identidad**. Como Appwrite usa correos, internamente la app mapeará la cédula a un correo virtual (`[cedula]@politik.com`) para iniciar sesión con Appwrite, ocultando este detalle al usuario.
- **Validación de Cédula:** Es obligatorio usar el algoritmo del Módulo 10 Ecuatoriano en los formularios.
- **Creación de Cuentas (Jerárquica):** NO HAY AUTOREGISTRO. El Coordinador Provincial crea al de Recinto. El de Recinto crea al Veedor de Mesa. El formulario pide: Cédula, Nombres, Apellidos, Teléfono, Correo real. El correo real se guarda en base de datos para notificaciones/recuperación de clave.
- **Seguridad de Contraseñas:** Todo usuario nuevo inicia con la clave `Ecuador2026`. El sistema debe forzar al usuario a cambiarla en su primer inicio de sesión.
- **Flujo de Veedor:** 
  - 2 actas por mesa (Alcalde y Prefecto). 
  - La suma de votos (candidatos + nulos + blancos) **nunca puede ser mayor** al total de sufragantes.
  - El GPS y la nitidez de la foto son obligatorios y bloqueantes.
  - Flujo Offline (Hive) con sincronización en segundo plano.

## 6. Gestión del Directorio `.context`
- **`rules.md`**: Supremo. Solo actualizable con permiso.
- **`architecture.md`**: Fijo. No eliminable, no actualizable.
- **`roadmap.md`**: Volátil. Llenado solo bajo autorización al iniciar un Sprint/Fase grande.
- **`session.md`**: Volátil. Resumen de jornada. Actualizable, no eliminable.
- **`evaluacion.md`**: Rúbrica oficial del examen (115 puntos).
