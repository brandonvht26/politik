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
- **Backend as a Service:** Appwrite (Autenticación, Base de Datos, Storage)
- **State Management:** `flutter_bloc`
- **Autenticación Biométrica:** `local_auth`

## 2. Idioma
- **Desarrollo (Código):** Inglés. Variables, funciones, clases, comentarios en el código base deben estar en inglés (`UserRepository`, `loginUser`, `AuthBloc`).
- **Interfaz de Usuario (UI):** Español. Cualquier texto visible para el usuario final debe estar en español ("Iniciar Sesión", "Ingresa tu contraseña").

## 3. Guías de Estilo y Patrones
- **Arquitectura:** Clean Architecture + Vertical Slicing. (Revisar `architecture.md`).
- **Responsabilidad Única (SOLID):** Funciones y clases pequeñas y bien definidas.
- **UI Responsiva y Fluida:** (Revisar `skills/ui/SKILL.md`).

## 4. Gestión del Directorio `.context`
- **`rules.md`**: Supremo. Solo actualizable con permiso.
- **`architecture.md`**: Fijo. No eliminable, no actualizable.
- **`roadmap.md`**: Volátil. Llenado solo bajo autorización al iniciar un Sprint/Fase grande.
- **`session.md`**: Volátil. Resumen de jornada. Actualizable, no eliminable.
- **`skills/`**: Directorio de habilidades y patrones específicos (ej. `ui/SKILL.md`).
