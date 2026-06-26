# Roadmap de Implementación (Sprint: Proyecto Final 115 pts)

> **ATENCIÓN:** Archivo actualizado tras la consolidación de requerimientos (`prueba2.docx`). Las IAs (Opencode, etc) deben seguir estas fases estrictamente en orden.

## Fase 1: Setup Core & Entidades (Offline-First)
**Estado:** ⬜ Pendiente

**Tareas:**
- Crear algoritmo de validación de Cédula Ecuatoriana (Módulo 10) en `lib/core/utils/cedula_validator.dart`.
- Inicializar **Hive** en `lib/core/services/local_storage_service.dart`.
- Crear modelos/entidades para Veedores, Recintos y Actas (preparados para Hive `hive_generator`).

## Fase 2: Módulo de Autenticación & Usuarios (Appwrite + Bloc)
**Estado:** ⬜ Pendiente

**Tareas:**
- Integrar `appwrite` SDK.
- **UI & Bloc:** Pantalla de Login (Cédula + Contraseña).
- **Lógica Mapeo:** Convertir Cédula a `[cedula]@politik.com` antes de llamar a Appwrite Auth.
- **Cambio de Clave Forzoso:** Si al loguearse la clave usada es `Ecuador2026`, redirigir obligatoriamente a una pantalla `ForcePasswordChangePage`.
- Guardar sesión y rol del usuario localmente para mantener persistencia offline.

## Fase 3: Dashboards (Provincial y Recinto)
**Estado:** ⬜ Pendiente

**Tareas:**
- **Provincial:** 
  - Pantalla de lista de recintos. 
  - Formulario de creación de recintos y de Coordinadores de Recinto.
  - Gráficos/Dashboard de votos consolidados.
- **Recinto:** 
  - Pantalla para listar JRVs.
  - Formulario de creación de Veedores de Mesa (pidiendo Cédula, Nombres, Correo Real, etc).
  - Funcionalidad para reasignar veedor a otra mesa.

## Fase 4: Flujo Crítico del Veedor (Offline + UI)
**Estado:** ⬜ Pendiente

**Tareas:**
- **UI:** `MisMesasPage` listando las mesas asignadas al veedor.
- **Formulario:** Ingreso de votos (5 partidos, nulos, blancos, sufragantes). Validar: `Suma Votos <= Sufragantes`.
- **Cámara & Sensores:** Integrar `image_picker` + `image_blur_detection`. Rechazar foto si la varianza Laplaciana es muy baja. Adquirir lat/long con `geolocator`.
- **Hive:** Guardar el registro completo en la caja local de actas con el estado `isSynced = false`.

## Fase 5: Servicio de Sincronización (Appwrite Cloud)
**Estado:** ⬜ Pendiente

**Tareas:**
- Background worker / Listener de conectividad (`connectivity_plus`).
- Al detectar red, iterar sobre la caja Hive buscando `isSynced == false`.
- Subir foto al **Storage Bucket** -> Obtener `image_id`.
- Guardar documento en **Database** -> Si es exitoso, actualizar Hive a `isSynced = true`.
