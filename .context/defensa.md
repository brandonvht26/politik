# Dominio del Problema — Defensa de la Prueba

> **Propósito:** Este archivo contiene los conceptos del dominio electoral que el docente (Ing. Juan Carlos González) ha solicitado que se comprendan antes de la prueba. También documenta las opciones técnicas para la detección de imágenes borrosas en Flutter.

---

## 1. ¿Qué es una Junta Receptora del Voto (JRV) / Mesa Electoral?

Es un **organismo electoral temporal** conformado por ciudadanos ecuatorianos designados por el Consejo Nacional Electoral (CNE) mediante sorteo público. Cada JRV opera en un recinto electoral el día de las elecciones.

### Composición:
- **Presidente/a** — Dirige la mesa, toma decisiones operativas.
- **Secretario/a** — Registra los eventos en actas, maneja documentos.
- **Vocales (1-3)** — Apoyan en las funciones generales de la mesa.

### Funciones principales (4 fases del día electoral):

| Fase | Qué hacen | Horario aprox. |
|---|---|---|
| **1. Instalación** | Se presentan, reciben el material electoral del CNE, verifican que las urnas estén vacías, las cierran con seguridades | 06:30 - 07:00 |
| **2. Votación** | Reciben a los electores, verifican identidad (cédula/pasaporte), registran firma/huella en el padrón, entregan papeletas, supervisan el voto secreto | 07:00 - 17:00 |
| **3. Escrutinio** | Cierran la votación, abren las urnas, cuentan votos uno a uno, llenan las actas de escrutinio con los resultados, firman | 17:00 - ~20:00 |
| **4. Embalaje y envío** | Organizan el paquete electoral (actas, materiales, papeletas sobrantes) y lo entregan al personal del CNE | Después del escrutinio |

### Dato clave para la app:
La JRV es donde **se genera la evidencia documental** (las actas). Nuestra app permite que los veedores capturen fotográficamente estas actas como evidencia, validando que la foto no sea borrosa antes de subirla.

---

## 2. ¿Qué es un Acta de Escrutinio?

Es el **documento oficial y público** donde los miembros de la JRV registran los resultados del conteo de votos. Es la prueba física de la voluntad popular de esa mesa específica.

### Contenido del acta:
- Número de papeletas utilizadas y sobrantes.
- Cantidad de votos obtenidos por **cada candidato o lista**.
- Desglose de **votos blancos** y **votos nulos**.
- **Firmas** de todos los miembros de la mesa.
- Firmas de los delegados de organizaciones políticas (si estuvieron presentes).

### ¿Para qué sirve?
1. **Base de la voluntad popular** — Es la prueba documental de cómo votó la ciudadanía en esa mesa.
2. **Transparencia y auditoría** — Al ser documento público, los delegados y observadores pueden verificar que los resultados sean fidedignos.
3. **Generación de resultados** — Es el insumo principal para el sistema informático del CNE que procesa y transmite los resultados nacionales.
4. **Seguridad jurídica** — Al estar firmada por los responsables, valida el escrutinio y reduce el riesgo de alteraciones.

### Proceso después del llenado:
1. Una copia se **pega en un lugar visible** del recinto electoral (para conocimiento público).
2. Una copia se entrega a los **delegados de las organizaciones políticas**.
3. El acta oficial (generalmente de color amarillo) se procesa para ingresar los datos al sistema del CNE.

### ¿Por qué fotografiar el acta?
El veedor captura una foto del acta como **evidencia independiente** del resultado. Si existieran discrepancias entre lo que el CNE reporta y lo que el acta física dice, la foto sirve como prueba. **Por eso la foto NO puede ser borrosa** — debe ser legible para tener valor como evidencia.

---

## 3. ¿Qué es un Veedor Electoral de Partido?

Es importante distinguir dos figuras que el inge menciona:

### a) Delegado de Organización Política (Veedor de Partido)
Es una persona **acreditada por el CNE en representación de un partido político, movimiento o alianza**. Su misión es defender los intereses de su organización vigilando el proceso.

**Funciones el día de las elecciones:**

| Función | Detalle |
|---|---|
| **Presencia constante** | Puede estar en la JRV desde la instalación, durante la votación, el escrutinio y hasta la proclamación de resultados |
| **Observación y reclamos** | Puede formular observaciones o reclamos sobre la actuación de los miembros de la mesa. Estos deben resolverse de inmediato y registrarse en acta |
| **Documentación** | Puede firmar las actas de instalación y escrutinio si lo desea |
| **Obtener resultados** | Puede solicitar copias de los resultados finales firmados por el presidente/secretario de la mesa |

**Prohibiciones:**
- ❌ Interferir en el acto de votación.
- ❌ Realizar proselitismo político dentro del recinto.
- ❌ Manipular materiales electorales.

### b) Observador Electoral (Veedor Ciudadano)
Es una figura de **control social** (ciudadano u organismo nacional/internacional) acreditado por el CNE. A diferencia del delegado de partido, su rol es validar la **transparencia general** del proceso, no defender los intereses de un partido específico.

### Tabla comparativa:

| Aspecto | Delegado de Partido | Observador/Veedor Ciudadano |
|---|---|---|
| **Representa a** | Un partido/movimiento político | La ciudadanía / sociedad civil |
| **Enfoque** | Defender intereses de su organización | Validar transparencia del proceso |
| **Lugar de acción** | Principalmente en la JRV asignada | En todo el proceso y recintos |
| **Motivación** | Partidista | Democrática / institucional |

### ¿Cómo se relaciona con nuestra app?
Nuestra app está diseñada para el **veedor/delegado de partido**. El flujo es:
1. Se autentica en la app (con credenciales o biometría).
2. Llega al recinto electoral y se dirige a su JRV asignada.
3. Durante/después del escrutinio, fotografía el acta de escrutinio.
4. La app valida que la foto sea nítida (no borrosa).
5. Si pasa la validación, se sube al servidor (Appwrite Storage) como evidencia.
6. Si NO pasa, se le pide que tome otra foto.

---

## 4. Detección de Imágenes Borrosas en Flutter

> **🟢 DECISIÓN TOMADA:** Se usará la **Opción A: `image_blur_detection`** (paquete puro Dart). Decisión del desarrollador (Brandon) — 2025-06-25.

El Ing. González menciona específicamente que la app debe **validar que no se suban fotos borrosas**. Esto es el reto tecnológico crítico del proyecto. A continuación las opciones evaluadas (se eligió la Opción A):

### Opción A: `image_blur_detection` (Paquete puro Dart) ⭐ RECOMENDADA

**Paquete:** [`image_blur_detection`](https://pub.dev/packages/image_blur_detection)

**Ventajas:**
- ✅ Puro Dart, no requiere bindings nativos.
- ✅ Funciona en Android, iOS, Web — todas las plataformas.
- ✅ Implementa Varianza del Laplaciano internamente.
- ✅ API simple: un validador que retorna si la imagen pasa o no.
- ✅ Thresholds configurables.
- ✅ Detecta blur, brillo y contraste (todo lo que necesitamos).
- ✅ Ideal para validación de documentos y actas.

**Desventajas:**
- ⚠️ Paquete relativamente nuevo (verificar mantenimiento).
- ⚠️ Procesamiento en el main thread (usar Isolate para imágenes grandes).

**Ejemplo de uso:**
```dart
import 'package:image_blur_detection/image_blur_detection.dart';

Future<void> validateActaPhoto(File imageFile) async {
  final imageBytes = await imageFile.readAsBytes();
  final validator = ImageQualityValidator();
  final result = await validator.validate(imageBytes);

  if (result.isValid) {
    // Foto nítida → permitir subida
  } else {
    // Foto borrosa → mostrar error, pedir nueva foto
    // result.issues contiene: QualityIssue.blur, brightness, contrast, etc.
  }
}
```

**Dependencia:**
```yaml
image_blur_detection: ^1.0.1
```

---

### Opción B: `opencv_dart` (OpenCV para Flutter)

**Paquete:** [`opencv_dart`](https://pub.dev/packages/opencv_dart)

**Ventajas:**
- ✅ Usa OpenCV (estándar de la industria para visión por computador).
- ✅ Control total sobre el algoritmo y threshold.
- ✅ Muy robusto para procesamiento de imágenes.
- ✅ Permite análisis en tiempo real del feed de cámara.

**Desventajas:**
- ⚠️ Requiere bindings nativos (más pesado, setup más complejo).
- ⚠️ Aumenta significativamente el tamaño del APK (+20-40 MB).
- ⚠️ Configuración más compleja en iOS.
- ⚠️ Requiere gestión manual de memoria (`dispose()`).

**Ejemplo de uso:**
```dart
import 'package:opencv_dart/opencv_dart.dart' as cv;

bool isBlurry(String imagePath, {double threshold = 100.0}) {
  final mat = cv.imread(imagePath);
  final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
  final laplacian = cv.Laplacian(gray, cv.CV_64F);
  final stdDev = cv.stdDev(laplacian);
  final variance = stdDev.val1 * stdDev.val1;

  mat.dispose();
  gray.dispose();
  laplacian.dispose();

  return variance < threshold; // Si varianza < threshold → borrosa
}
```

**Dependencia:**
```yaml
opencv_dart: ^1.4.0
```

---

### Opción C: Implementación manual con `image` package (Dart puro)

**Paquete:** [`image`](https://pub.dev/packages/image) (procesamiento de imágenes puro Dart)

**Ventajas:**
- ✅ Sin dependencias nativas.
- ✅ Control total del algoritmo.
- ✅ Ligero.

**Desventajas:**
- ⚠️ Debes implementar el Laplaciano manualmente (kernel convolution).
- ⚠️ Más código, más probabilidad de bugs.
- ⚠️ No viene con blur detection prebuilt.

---

### ¿Cómo funciona la Varianza del Laplaciano? (Para la defensa)

Es el **algoritmo estándar** para medir la nitidez de una imagen:

1. **Convertir a escala de grises** — Simplifica el cálculo (1 canal en vez de 3).
2. **Aplicar el operador Laplaciano** — Es un filtro de detección de bordes. Las imágenes nítidas tienen muchos bordes (texto legible, líneas definidas en el acta). Las borrosas tienen bordes difusos.
3. **Calcular la varianza** — Una varianza ALTA = muchos bordes definidos = imagen nítida. Una varianza BAJA = pocos bordes = imagen borrosa.
4. **Comparar con un threshold** — Si la varianza < threshold, la imagen es borrosa y se rechaza.

```
Imagen nítida → Laplaciano detecta muchos bordes → Varianza ALTA (ej. 350) → ✅ Aceptada
Imagen borrosa → Laplaciano detecta pocos bordes → Varianza BAJA (ej. 25)  → ❌ Rechazada
```

**¿Por qué este algoritmo para actas electorales?**
Las actas tienen texto escrito (números de votos, nombres de candidatos). El texto tiene bordes muy definidos. Si la foto es borrosa, esos bordes se pierden y la varianza cae drásticamente. Es perfecto para nuestro caso de uso.

---

## 5. Resumen del Flujo Completo de la App

```
┌─────────────────────────────────────────────────────────────┐
│                      VEEDOR ELECTORAL                        │
│                                                              │
│  1. Abre la app                                              │
│  2. Se autentica (email/password + biometría futura)         │
│  3. Llega al recinto electoral                               │
│  4. Después del escrutinio, toma foto del acta               │
│  5. La app analiza la foto:                                  │
│     ├── ✅ Nítida → Sube a Appwrite Storage                  │
│     └── ❌ Borrosa → "La foto no es legible, toma otra"      │
│  6. El acta queda respaldada como evidencia digital           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Valor de la solución:
- **Problema real:** Los veedores toman fotos borrosas de las actas, que luego no sirven como evidencia.
- **Nuestra solución:** Validación en el dispositivo ANTES de subir, ahorrando datos y asegurando calidad.
- **Justificación técnica de Appwrite:** Mayor cantidad de peticiones por hora vs Supabase, ideal para la defensa donde habrá múltiples equipos probando simultáneamente (evitar `429 Too Many Requests`).
