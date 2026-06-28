# Configuración de Base de Datos y Persistencia

> **ATENCIÓN:** Esquema oficial de base de datos adaptado para la rúbrica del examen. Las IAs generadoras de código deben basarse en estos esquemas.

## 1. Arquitectura de Appwrite Cloud

### Base de Datos: `politik_db`

#### Colección: `profiles` (Usuarios Adicionales)
Dado que Appwrite Auth gestiona la autenticación, usaremos esta colección para los datos extendidos de los usuarios creados jerárquicamente.
- **ID:** Preferiblemente el mismo `userId` de Appwrite Auth o la Cédula.
- **Atributos:**
  - `cedula` (String, Unique)
  - `nombres` (String)
  - `apellidos` (String)
  - `telefono` (String)
  - `correo_real` (String) -> Para recuperación.
  - `rol` (String) -> 'provincial', 'recinto', 'veedor'
  - `recinto_id` (String, nullable) -> A qué recinto pertenece (si aplica).
  - `mesa_id` (String, nullable) -> A qué mesa está asignado (si es veedor).

#### Colección: `recintos`
- **Atributos:**
  - `canton` (String)
  - `parroquia` (String)
  - `nombre` (String)
  - `num_mesas` (Integer)

#### Colección: `organizaciones_politicas`
Contiene los candidatos precargados (12 en total) tanto para Alcaldía como Prefectura.
- **Atributos:**
  - `nombre_partido` (String)
  - `lista` (Integer o String)
  - `candidato` (String)
  - `dignidad` (String) -> 'alcalde' o 'prefecto'

#### Colección: `actas`
- **Permisos:** Document Security habilitado. Veedores no pueden ver actas de otros recintos.
- **Atributos:**
  - `recinto_id` (String)
  - `mesa_id` (String)
  - `tipo` (String) -> 'alcalde' o 'prefecto'
  - `votos_partidos` (String/JSON) -> Serialización de votos.
  - `votos_blancos` (Integer)
  - `votos_nulos` (Integer)
  - `total_sufragantes` (Integer)
  - `latitud` (Double)
  - `longitud` (Double)
  - `image_id` (String) -> Referencia al Bucket.

### Storage Bucket: `actas_images`
- Contiene las fotos nítidas. Solo escritura permitida a veedores autenticados. Lectura permitida a coordinadores.

## 2. Esquemas Locales (Hive) - Offline First
Solo es obligatorio para el Veedor de Mesa.

### Box: `actas_locales`
- **Type:** `ActaEscrutinioLocal`
- **Campos adicionales:** 
  - `bool isSynced` (False al crear, True al subir a Appwrite exitosamente).
  - `String uuid` (ID temporal local).
  - `String filePath` (Ruta local de la imagen temporal antes de subir a Appwrite).

### Box: `session`
- Guardar `cedula`, `rol`, `recinto_id` del usuario logueado para que la app se abra directamente en el dashboard correspondiente sin internet.
