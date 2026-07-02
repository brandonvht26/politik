import 'package:flutter/material.dart';

class AppColors {
  // Paleta Institucional - Gobierno Ecuatoriano
  static const Color primary = Color(0xFF1B2956); // Azul profundo Gobierno
  static const Color secondary = Color(0xFFDB2729); // Rojo Gobierno
  static const Color accent = Color(0xFFF7B216); // Amarillo Gobierno
  
  static const Color background = Color(0xFFF8FAFC); // Gris muy claro para el fondo
  static const Color surface = Colors.white; // Fondo de tarjetas / contenedores
  
  static const Color textPrimary = Color(0xFF0F172A); // Texto principal oscuro
  static const Color textSecondary = Color(0xFF64748B); // Texto secundario grisáceo
  
  static const Color error = Color(0xFFDC2626); // Rojo para errores
  static const Color success = Color(0xFF16A34A); // Verde para éxito (ej. subida correcta)

  // Gradients for UI upgrade
  static const LinearGradient metallicGradient = LinearGradient(
    colors: [Color(0xFF1B2956), Color(0xFF283C7E), Color(0xFF1B2956)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF7B216), Color(0xFFFFD54F), Color(0xFFF7B216)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
