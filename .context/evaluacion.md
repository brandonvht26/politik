# Rúbrica y Requerimientos del Examen (Control Electoral)

> **ATENCIÓN:** Este documento resume estrictamente todo lo que se evaluará para obtener la **Nota Máxima (100/100) + Puntos Extra (15/15)**. Todo el desarrollo debe alinearse con estos requerimientos.

## 1. Roles y GestiÃ³n de Usuarios (GestiÃ³n JerÃ¡rquica)
No existe auto-registro. La creaciÃ³n es en cascada:
1. **Coordinador Provincial:** Crea recintos y cuentas de Coordinadores de Recinto.
2. **Coordinador de Recinto:** Crea cuentas de Veedores de Mesa y los asigna a sus JRV.
3. **Veedor de Mesa:** Registra datos, toma fotos de actas y corrige.

### 1.1 Credenciales y AutenticaciÃ³n (8 puntos)
- **Login:** El nombre de usuario DEBE SER la **CÃ©dula de Identidad**. 
  > *DecisiÃ³n TÃ©cnica Appwrite:* Como Appwrite requiere un email para auth tradicional, internamente concatenaremos la cÃ©dula con un dominio (ej. `[cedula]@politik.com`), pero la UI solo pedirÃ¡ la cÃ©dula.
- **Campos obligatorios:** CÃ©dula, Nombres, Apellidos, TelÃ©fono, Correo ElectrÃ³nico real (usado para recuperaciÃ³n).
- **ContraseÃ±a inicial:** Todo usuario nuevo tendrÃ¡ `Ecuador2026`. En el primer login, DEBE ser obligado a cambiarla.
- **RecuperaciÃ³n:** Flujo nativo de Appwrite para restablecer contraseÃ±a mediante el correo real registrado.

## 2. Requerimientos Funcionales por Rol

### 2.1 Veedor de Mesa (18 puntos)
- Solo puede ver sus mesas asignadas.
- **Registro de actas:** 2 actas por mesa (Alcalde y Prefecto).
- **Carga de datos:** 5 organizaciones polÃ­ticas precargadas, votos nulos, votos blancos y **total de sufragantes**.
- **ValidaciÃ³n de Votos:** Los votos de los candidatos NO pueden exceder el total de sufragantes.
- **Captura de Acta:** Foto validada localmente por nitidez. Si es borrosa, se rechaza en la UI.
- **GeolocalizaciÃ³n:** Al tomar la foto, registrar automÃ¡ticamente las coordenadas GPS. Si el permiso estÃ¡ denegado, la app se bloquea con aviso.
- **CorrecciÃ³n:** Puede corregir datos o foto de un acta ya subida en cualquier momento.

### 2.2 Coordinador de Recinto (10 puntos)
- Ve las mesas de su recinto y su estado.
- Crea veedores y los asigna a las mesas.
- Reasigna veedores en caso de ausencia.
- Ve el detalle de cualquier mesa de su recinto y **puede corregir actas** igual que el veedor.

### 2.3 Coordinador Provincial (8 puntos)
- Ve el listado de recintos existentes.
- Crea nuevos recintos (CantÃ³n, Parroquia, Nombre, # de JRV).
- Crea Coordinadores de Recinto y los asigna.
- Ve el avance (mesas registradas vs pendientes) y revisa el GPS de las actas registradas.

## 3. Arquitectura y Calidad TÃ©cnica (6 puntos)
- **SeparaciÃ³n de capas:** Clean Architecture (ya establecido en `architecture.md`).
- **Estado (BLoC):** Uso obligatorio de representaciÃ³n de estados en la UI: Carga, Ã‰xito, Error. **No se aceptan pantallas en blanco**.
- **Reglas de Acceso (Appwrite):** Configurar permisos a nivel BD para que los veedores no puedan leer/escribir mesas ajenas, y los coordinadores de recinto solo su recinto.

## 4. DiseÃ±o e Interfaz UI (20 puntos)
- NavegaciÃ³n coherente y flujos diferenciados.
- Feedback visual claro en toda operaciÃ³n (carga, error, validaciones).
- Consistencia en tipografÃ­a (`Lexend`, `PlusJakartaSans`), jerarquÃ­a y espaciado (ya en `skills/ui/SKILL.md`).

## 5. Entregable Adicional: SincronizaciÃ³n Offline (+15 puntos)
- Implementar persistencia local (recomendado **Hive** o **Isar/Drift**) exclusivamente para el flujo del Veedor.
- El veedor debe poder registrar los votos y tomar las fotos sin internet.
- SincronizaciÃ³n automÃ¡tica silenciosa cuando recupere la conexiÃ³n.
- **Estrategia de Conflictos a Defender:** "La Ãºltima escritura local del veedor predomina si no habÃ­a conexiÃ³n, pero se verifica el `updated_at` en el backend para evitar sobrescribir correcciones hechas por el Coordinador de Recinto".

## 6. SustentaciÃ³n / Defensa AcadÃ©mica (30 puntos)
- ExplicaciÃ³n del cÃ³digo (12 pts).
- Justificar uso de Appwrite vs Supabase (rate limits de Supabase causan problemas en pruebas masivas) (10 pts).
- Justificar BLoC (desacoplamiento total, escalabilidad, trazabilidad de eventos) (10 pts).
- Justificar Varianza del Laplaciano para nitidez (explicado en `defensa.md`).
- Limitaciones y mejoras (8 pts).

## 7. Penalizaciones CrÃ­ticas
- Falta del archivo `.apk` reduce la nota 30 puntos directos.
- Entrega tardÃ­a no aceptada.
