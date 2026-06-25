---
name: ui_design_patterns
description: Reglas y patrones obligatorios para el diseño de interfaces en la aplicación.
---

# Patrones de Diseño UI y Reglas de Interfaz

## 1. Estado Global de Colores (Tema)
- **Nunca inyectar colores manual o directamente ("hardcoded")** en los componentes individuales (ej. `color: Colors.blue`).
- Todo color debe provenir del `Theme.of(context)` definido en el `AppTheme` y `AppColors`. Esto permite aplicar cambios globales instantáneos.
- **Colores Transversales:**
  - `Warning / Alerta`: Amarillo (usar el color `accent` definido).
  - `Error / Destructivo`: Rojo (`error`).
  - `Satisfacción / Éxito`: Verde (`success`). Usar estos semánticamente en operaciones CRUD.

## 2. Animaciones y Micro-interacciones
La interfaz debe sentirse viva y Premium:
- **Renderización/Eliminación:** Usar `AnimatedList`, `AnimatedContainer` o `AnimatedSwitcher` para montajes y desmontajes. Nunca cambiar de estado bruscamente.
- **Pulsación de Botones:** Todo botón debe tener feedback táctil. (Ripple effect natural de Material 3).
- **Focus en Inputs:** Al seleccionar un campo de texto, el borde o sombra debe transicionar suavemente a un color primario.
- **Mutación de datos:** Cuando un número o dato cambie en pantalla (ej. un contador de votos), usar animaciones sutiles (ej. un fade o un slide corto).

## 3. Accesibilidad y Navegación de Teclado
- **Inputs Secuenciales:** El teclado del dispositivo debe usar `TextInputAction.next` y un nodo de `FocusNode` para que al presionar **Enter**, el cursor pase automáticamente al siguiente campo, mejorando enormemente la velocidad de escritura del usuario. En el último campo, usar `TextInputAction.done`.

## 4. Prevención de Solapamiento
- **NUNCA** el teclado debe ocultar un campo de texto que se esté editando o el botón de confirmación.
- Asegurarse de envolver vistas con formularios dentro de un `SingleChildScrollView`.
- Si el teclado se despliega, el usuario debe poder hacer scroll libremente.

## 5. Diseño Responsive y SafeArea
- **Android Botones vs Gestos:** Usar siempre `SafeArea` correctamente (bottom: true, top: true) para que la UI use todo el espacio disponible si el usuario navega por gestos, pero que respete el espacio de la barra de navegación si usa los antiguos botones fijos de Android.
- **Botones de Retroceso:** Toda pantalla anidada debe tener un medio obvio para retroceder (AppBar nativo con leading icon). No sobreescribir la lógica de retroceso de Android sin una buena razón (ej. no dejar que salgan accidentalmente a la mitad de una carga).

## 6. Tipografía
- **Fuente Principal (Texto base y lectura):** `Lexend`. Se aplica globalmente como fuente por defecto en el `ThemeData`.
- **Fuente de Títulos y Encabezados:** `PlusJakartaSans`. Se debe usar estrictamente para los atributos `display`, `headline` y `title` del `TextTheme`.
- No inyectar fuentes directamente usando `fontFamily` en los `TextStyle` individuales a menos que sea estrictamente necesario para sobreescribir el tema en un caso muy aislado. Usa siempre `Theme.of(context).textTheme...`.
