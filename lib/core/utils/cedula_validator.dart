/// Strict Ecuadorian ID (Cédula) validator using the official Modulo 10
/// algorithm.
///
/// Rules implemented:
/// - 10 numeric digits.
/// - First two digits are a valid province code (01-24, plus 30 for
///   Ecuadorians abroad).
/// - Third digit is in the natural-person range (0-5).
/// - Check digit (10th) matches the Modulo 10 calculation.
class CedulaValidator {
  CedulaValidator._();

  static const List<int> _coefficients = [2, 1, 2, 1, 2, 1, 2, 1, 2];
  static const int _minProvince = 1;
  static const int _maxProvince = 24;
  static const int _abroadProvince = 30;

  /// Validates the given [cedula] and returns a structured result.
  static CedulaValidationResult validate(String cedula) {
    if (cedula.trim().isEmpty) {
      return const CedulaValidationResult.invalid(
        CedulaValidationError.empty,
      );
    }

    final clean = cedula.trim();

    if (clean.length != 10) {
      return const CedulaValidationResult.invalid(
        CedulaValidationError.wrongLength,
      );
    }

    if (!RegExp(r'^\d{10}$').hasMatch(clean)) {
      return const CedulaValidationResult.invalid(
        CedulaValidationError.notNumeric,
      );
    }

    final digits = clean.split('').map(int.parse).toList();

    final province = digits[0] * 10 + digits[1];
    if (province < _minProvince ||
        (province > _maxProvince && province != _abroadProvince)) {
      return const CedulaValidationResult.invalid(
        CedulaValidationError.invalidProvince,
      );
    }

    // Third digit for natural persons must be between 0 and 5.
    if (digits[2] > 5) {
      return const CedulaValidationResult.invalid(
        CedulaValidationError.invalidThirdDigit,
      );
    }

    final calculatedCheckDigit = _calculateCheckDigit(digits);
    if (calculatedCheckDigit != digits[9]) {
      return const CedulaValidationResult.invalid(
        CedulaValidationError.invalidCheckDigit,
      );
    }

    return const CedulaValidationResult.valid();
  }

  /// Convenience method that returns `true` when the ID is valid.
  static bool isValid(String cedula) => validate(cedula).isValid;

  static int _calculateCheckDigit(List<int> digits) {
    var total = 0;

    for (var i = 0; i < 9; i++) {
      var product = digits[i] * _coefficients[i];
      if (product >= 10) {
        product -= 9;
      }
      total += product;
    }

    final remainder = total % 10;
    return remainder == 0 ? 0 : 10 - remainder;
  }
}

/// Possible validation errors for an Ecuadorian ID.
enum CedulaValidationError {
  empty,
  wrongLength,
  notNumeric,
  invalidProvince,
  invalidThirdDigit,
  invalidCheckDigit,
}

/// Result of validating a cédula.
class CedulaValidationResult {
  final bool isValid;
  final CedulaValidationError? error;

  const CedulaValidationResult.valid()
      : isValid = true,
        error = null;

  const CedulaValidationResult.invalid(this.error) : isValid = false;

  /// Human-readable error message in Spanish (UI language).
  String? get message {
    switch (error) {
      case null:
        return null;
      case CedulaValidationError.empty:
        return 'La cédula es obligatoria.';
      case CedulaValidationError.wrongLength:
        return 'La cédula debe tener 10 dígitos.';
      case CedulaValidationError.notNumeric:
        return 'La cédula solo debe contener números.';
      case CedulaValidationError.invalidProvince:
        return 'Los dos primeros dígitos de la cédula no son válidos.';
      case CedulaValidationError.invalidThirdDigit:
        return 'El tercer dígito de la cédula no es válido.';
      case CedulaValidationError.invalidCheckDigit:
        return 'La cédula no supera la validación del Módulo 10.';
    }
  }
}
