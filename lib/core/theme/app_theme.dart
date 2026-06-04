import 'package:flutter/material.dart';

class AppTheme {
  // --- Violet principal ---
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4C1D95), // violet très sombre
      Color(0xFF7C3AED), // violet vif
      Color(0xFFA855F7), // violet moyen
    ],
  );

  // --- Orange secondaire (remplace le rose/rouge) ---
  static const secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF97316), // orange vif
      Color(0xFFFB923C), // orange clair
      Color(0xFFFED7AA), // orange pâle
    ],
  );

  static const successGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
  );

  static const errorGradient = LinearGradient(
    colors: [Color(0xFFD32F2F), Color(0xFFFF5252)],
  );

  // --- Fonds sombres à dominante violette ---
  static const backgroundColor = Color(0xFF0F0A1E);
  static const cardColor = Color(0xFF1A1040);
  static const surfaceColor = Color(0xFF241858);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Poppins',
      primaryColor: const Color(0xFF7C3AED),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7C3AED),
        secondary: Color(0xFFF97316),
        surface: surfaceColor,
        background: backgroundColor,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
