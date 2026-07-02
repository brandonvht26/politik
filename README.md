# Politik - Sistema de Control Electoral

Aplicación móvil desarrollada en Flutter para la gestión y control electoral, con un enfoque "offline-first" y sincronización en tiempo real utilizando Appwrite.

## Características Principales

*   **Offline-First**: Funcionalidad garantizada incluso sin conexión a internet. Los datos se almacenan localmente en Hive y se sincronizan cuando hay conexión.
*   **Roles Jerárquicos**: Sistema de gestión dividido en tres niveles:
    *   **Coordinador Provincial**: Gestión total de recintos y asignación de Coordinadores de Recinto. Monitoreo global de resultados.
    *   **Coordinador de Recinto**: Asignación y gestión de Veedores para cada mesa de su recinto. Monitoreo de actas subidas en su recinto.
    *   **Veedor**: Ingreso de resultados de actas (Alcalde y Prefecto), captura fotográfica del acta y geolocalización.
*   **Arquitectura Limpia**: Separación de capas (Domain, Data, Presentation) y uso del patrón BLoC para la gestión del estado.
*   **Diseño Premium**: Interfaz moderna y elegante utilizando los colores oficiales (Azul, Rojo, Amarillo).

## Requisitos Previos

*   Flutter SDK (>=3.0.0)
*   Instancia de Appwrite (Local o Cloud)
*   Archivo `.env` en la raíz del proyecto.

## Instrucciones para Correr el Proyecto

1.  **Clonar el repositorio y descargar dependencias:**
    ```bash
    flutter clean
    flutter pub get
    ```

2.  **Configurar Variables de Entorno (`.env`):**
    Crea un archivo `.env` en la raíz del proyecto con la siguiente estructura (reemplaza con tus IDs de Appwrite):
    ```env
    APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
    APPWRITE_PROJECT_ID=tu_project_id
    APPWRITE_DATABASE_ID=tu_database_id
    APPWRITE_RECINTOS_COLLECTION_ID=tu_recintos_id
    APPWRITE_PROFILES_COLLECTION_ID=tu_profiles_id
    APPWRITE_ACTAS_COLLECTION_ID=tu_actas_id
    APPWRITE_ORGANIZACIONES_POLITICAS_COLLECTION_ID=tu_organizaciones_id
    APPWRITE_PARROQUIAS_COLLECTION_ID=tu_parroquias_id
    APPWRITE_STORAGE_BUCKET_ID=tu_bucket_id
    APPWRITE_API_KEY=tu_api_key_servidor
    ```

3.  **Ejecutar la App:**
    ```bash
    flutter run
    ```
    *Para construir el APK:*
    ```bash
    flutter build apk
    ```

---

## Modelo de Datos del Backend (Appwrite)

La base de datos en Appwrite debe contener las siguientes colecciones:

### 1. Colección `profiles` (Perfiles de Usuario)
Contiene la información adicional de cada usuario registrado en Appwrite Auth.
*   `cedula` (String, Obligatorio)
*   `nombre_completo` (String, Obligatorio)
*   `rol` (String, Obligatorio) -> Valores: `"coordinador_provincial"`, `"coordinador_recinto"`, `"veedor"`
*   `recinto_id` (String, Opcional) -> ID del recinto asignado (para Coordinadores de Recinto y Veedores).
*   `mesa_id` (String, Opcional) -> Número de mesas separadas por coma (ej. `"1, 2, 3"`) para los Veedores.

### 2. Colección `recintos`
*   `canton` (String, Obligatorio)
*   `parroquia` (String, Obligatorio)
*   `nombre` (String, Obligatorio)
*   `num_mesas` (Integer, Obligatorio)

### 3. Colección `actas`
*   `recinto_id` (String, Obligatorio)
*   `id_jrv` (String, Obligatorio) -> Número de mesa
*   `dignidad` (String, Obligatorio) -> Valores: `"alcalde"`, `"prefecto"`
*   `votos_partidos` (String, Obligatorio) -> JSON Stringified con los votos (ej. `{"Movi - Perez": 100}`)
*   `votos_blancos` (Integer, Obligatorio)
*   `votos_nulos` (Integer, Obligatorio)
*   `total_sufragantes` (Integer, Obligatorio)
*   `latitud` (Double, Opcional)
*   `longitud` (Double, Opcional)
*   `image_id` (String, Obligatorio) -> ID del archivo en el Storage Bucket.

### 4. Colección `organizaciones_politicas`
*   `dignidad` (String, Obligatorio) -> Valores: `"alcalde"`, `"prefecto"`
*   `partido` (String, Obligatorio)
*   `candidato` (String, Obligatorio)

### 5. Colección `parroquias`
*   `nombre` (String, Obligatorio)

> **Nota:** El Storage Bucket debe tener permisos de `lectura` habilitados para `Role.any()` o usuarios autenticados para que se puedan visualizar las imágenes.

---

## Credenciales de Prueba

Para probar los tres niveles de jerarquía, utiliza las siguientes cédulas con la contraseña general. (Asegúrate de tener creados estos usuarios en **Appwrite Authentication** bajo el formato `cedula@politik.com` y con sus respectivos documentos en la colección `profiles`).

**Contraseña para todos los roles:** `Lahabana1.2`

### 1. Coordinador Provincial (Administrador General)
*   **Cédula:** `1754262911`
*   *(Rol en profiles: `coordinador_provincial`)*

### 2. Coordinador de Recinto
*   **Cédula:** `1723481121`
*   *(Rol en profiles: `coordinador_recinto`. Debe tener un `recinto_id` asignado)*

### 3. Veedor (Operador de Mesa)
*   **Cédula:** `1723481139`
*   *(Rol en profiles: `veedor`. Debe tener un `recinto_id` y `mesa_id` asignados)*
