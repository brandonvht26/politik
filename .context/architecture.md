# Architecture Guidelines

> **ATENCIÓN:** Este archivo **NO puede eliminarse ni actualizarse**. Es la guía definitiva sobre cómo se estructura el proyecto. Evita inventar estructuras o flujos que no estén definidos aquí.

## Patrón Arquitectónico
El proyecto sigue la **Clean Architecture** combinada con **Vertical Slicing** (segmentación por features).

## Estructura de Directorios

### `lib/core/`
Contiene toda la base sobre la cual se construye la aplicación. No depende de ningún feature.
- `theme/`: Paleta de colores, tipografías y `AppTheme` (Estado Global UI).
- `utils/`: Funciones compartidas (ej. validación de blur de imagen).
- `errors/`: Clases de fallo y excepciones personalizadas (`Failures`, `Exceptions`).
- `constants/`: Constantes de la aplicación, endpoints.
- `services/`: Configuración e inicialización de servicios externos (ej. `appwrite_client.dart`).

### `lib/features/`
Aquí se alojan los "slices" o módulos independientes de la app (ej. `auth`, `mesa_electoral`, `acta_escrutinio`).
Dentro de cada feature, se debe mantener una estructura Clean:
- `data/`
  - `models/`: Representación de datos serializados (JSON).
  - `datasources/`: Interacción directa con APIs o bases de datos locales/Appwrite.
  - `repositories_impl/`: Implementación de los repositorios del dominio.
- `domain/`
  - `entities/`: Clases puras de Dart que representan el modelo de negocio.
  - `repositories/`: Contratos (Interfaces/Abstract classes) de lo que la capa de datos debe implementar.
  - `usecases/`: Casos de uso de la aplicación (ej. `LoginUser`, `VerifyImageBlur`).
- `presentation/`
  - `bloc/` o `cubit/`: Lógica de presentación y manejo de estado.
  - `pages/`: Pantallas completas (Screens).
  - `widgets/`: Componentes UI específicos de este feature.

## Flujo de Datos Estricto
`UI (Pages)` -> `BLoC (State Management)` -> `UseCase` -> `Repository` -> `DataSource` -> `External Service (Appwrite / API)`
**NUNCA** se debe saltar una capa. La UI nunca debe acceder directamente al DataSource.
