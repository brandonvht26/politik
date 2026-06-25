# Roadmap

> **ATENCIÓN:** Archivo volátil. Solo se llena/actualiza cuando se ejecuta un plan grande y con **autorización explícita** del usuario. No puede eliminarse.

## Sprint Actual: Flujo de Veeduría "Offline-First" (Puntos Extra)

**Autorizado por el usuario:** 2025-06-25
**Objetivo:** Desarrollar todo el flujo crítico del Veedor de Mesa sin dependencia temporal de Appwrite (debido a rate limits). Se priorizará la UI, BLoC, Entidades y persistencia local usando Hive para asegurar los 15 puntos extra del examen.

---

### Fase 1: Setup Local & Entidades de Dominio
**Estado:** ⬜ Pendiente

**Archivos a crear:**
- Entidades puras en `lib/features/acta_escrutinio/domain/entities/` (Acta, Votos, JRV).
- Entidades de usuario `lib/features/auth/domain/entities/user_entity.dart`.
- Setup de dependencias: agregar `hive`, `hive_flutter`, `geolocator`.

### Fase 2: Persistencia Local (Hive)
**Estado:** ⬜ Pendiente

**Archivos a crear:**
- `lib/core/services/local_storage_service.dart` — Inicialización de Hive.
- `lib/features/acta_escrutinio/data/models/` — Modelos Hive (adaptadores).
- `lib/features/acta_escrutinio/data/datasources/acta_local_data_source.dart` — Guardar y leer actas pendientes de sincronizar (`isSynced = false`).

### Fase 3: Interfaz y Flujo de Veedor
**Estado:** ⬜ Pendiente

**Pantallas:**
- `MisMesasPage`: Listado de JRV asignadas (datos mockeados por ahora).
- `ActaFormPage`: Formulario con validación estricta (Votos Candidatos + Blancos + Nulos <= Sufragantes).
- `CameraPage`: Integración de `image_picker` con `image_blur_detection` para rechazar fotos borrosas. Captura simultánea de GPS con `geolocator`.

### Fase 4: Manejo de Estado (BLoC)
**Estado:** ⬜ Pendiente

- Implementar `ActaBloc` con estados explícitos: `ActaLoading`, `ActaSuccess`, `ActaError`.
- Prohibido dejar pantallas en blanco. Mostrar Snackbars y Loading Spinners.

### Fase 5: Autenticación (UI) & Roles
**Estado:** ⬜ Pendiente

- Pantalla de Login exigiendo **Cédula de Identidad**.
- Redirección basada en Rol (Coordinador Provincial, Coordinador de Recinto, Veedor).
- Flujo de cambio de contraseña forzoso si la clave es `Ecuador2026`.

### Fase 6: Reconexión Appwrite (Sincronización a la nube)
**Estado:** ⏸️ En pausa (hasta liberar IP)

- Mapeo de la Cédula a un email interno (`cedula@politik.com`) para `createEmailPasswordSession`.
- Sincronización en segundo plano de actas de Hive hacia Appwrite.
- Envío de enlace de recuperación (Password Recovery).

---

## Stack de Modelos de Inteligencia Artificial Disponibles
Para cada fase del roadmap, se debe asignar el modelo más apropiado:

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
