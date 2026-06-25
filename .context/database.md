# Configuración de Base de Datos y Persistencia

> **ATENCIÓN:** Este archivo documenta la estructura de datos, tanto local (Hive) como remota (Appwrite), y el mapeo entre ambas. Cualquier modelo de IA debe respetar estos esquemas al generar operaciones de lectura/escritura o consultas.

## 1. Arquitectura Offline-First
La aplicación prioriza la disponibilidad. Todas las operaciones de creación se escriben primero en la base de datos local (Hive). La sincronización hacia Appwrite se realiza en un segundo plano cuando se detecta conexión a internet.

- **Persistencia Local:** `Hive` (Bases de datos NoSQL basadas en cajas de clave-valor).
- **Backend Remoto:** `Appwrite Cloud` (BaaS).

---

## 2. Esquemas de Appwrite Cloud

### Base de Datos Principal
- **Database Name:** `politik_db`
- **Database ID:** Definido en `.env` como `APPWRITE_DATABASE_ID`

### Colección: `actas`
- **Collection ID:** Definido en `.env` como `APPWRITE_ACTAS_COLLECTION_ID`
- **Permisos:** Create, Read, Update habilitados para el rol `users` (usuarios autenticados).
- **Atributos:**
  | Atributo | Tipo | Descripción |
  | :--- | :--- | :--- |
  | `id_jrv` | String | Identificador de la Junta Receptora del Voto (Mesa). |
  | `dignidad` | String | Puede ser 'alcalde' o 'prefecto'. |
  | `votos_partidos` | String (JSON) | JSON serializado de la lista de `VotosPartidoModel`. |
  | `votos_blancos` | Integer | Cantidad de votos blancos. |
  | `votos_nulos` | Integer | Cantidad de votos nulos. |
  | `total_sufragantes`| Integer | Suma total de firmas/huellas en el padrón. |
  | `latitud` | Double | (Opcional) Coordenada GPS capturada al tomar la foto. |
  | `longitud` | Double | (Opcional) Coordenada GPS capturada al tomar la foto. |
  | `image_id` | String | El ID del archivo de imagen subido al Storage Bucket. |

### Storage Bucket: `actas_images`
- **Bucket ID:** Definido en `.env` como `APPWRITE_STORAGE_BUCKET_ID`
- **Uso:** Almacenar las fotos nítidas de las actas físicas.
- **Flujo de subida:** La foto debe subirse primero a este Bucket. El `id` devuelto por el Storage se asigna al campo `image_id` de la colección `actas`.

### Usuarios y Roles (Appwrite Auth)
- Appwrite Auth maneja la autenticación. 
- Debido a que Appwrite usa correo, el login en la UI (que pide Cédula) mapeará la cédula a un correo ficticio (ej. `0999999999@politik.com`) para interactuar con Appwrite Auth.
- La información adicional del usuario (nombres, roles como 'veedor', 'recinto', 'provincial') se almacenará en los **User Preferences** de Appwrite, o en una colección `users` si se requiere queries complejos.

---

## 3. Esquemas Locales (Hive)

Las cajas (Boxes) almacenan la representación local antes de subirla. Todos los adaptadores están generados con `hive_generator`.

### Box: `actas`
- **Type:** `ActaEscrutinioModel` (typeId: 2)
- **Campos principales:** Hereda de `ActaEscrutinioEntity` e incluye un campo crítico adicional: `bool isSynced` (Anotado en Hive).
- **Comportamiento:** 
  - Al guardar offline: `isSynced = false`.
  - La llave (Key) de la caja será el ID temporal (uuid) asignado localmente.
  - El servicio de sincronización leerá `Hive.box('actas').values.where((acta) => !acta.isSynced)`.

### Box: `votos_partido` (Embebido)
- **Type:** `VotosPartidoModel` (typeId: 1)
- **Comportamiento:** No tiene su propia caja, se guarda como una lista anidada dentro de `ActaEscrutinioModel`.

---

## 4. Reglas de Sincronización (Fase 6)
1. **Detección de Red:** Usar `connectivity_plus` para detectar reconexión.
2. **Prioridad:** Primero subir la imagen al Bucket. Si falla, detener el proceso de esa acta.
3. **Escritura Remota:** Con el `image_id` asegurado, crear el documento en la colección `actas`.
4. **Actualización Local:** Solo si el documento se crea exitosamente en Appwrite, actualizar el acta en Hive a `isSynced = true`. No eliminar de Hive (actuará como historial offline del veedor).

---

## 5. Variables de Entorno (`.env`)
Se requiere el paquete `flutter_dotenv` y el siguiente archivo `.env` en la raíz (ignorado en git):

```env
APPWRITE_PROJECT_ID=tu_project_id
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_DATABASE_ID=tu_database_id
APPWRITE_ACTAS_COLLECTION_ID=tu_collection_id
APPWRITE_STORAGE_BUCKET_ID=tu_bucket_id
```
