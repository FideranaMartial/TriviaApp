import 'package:flutter/material.dart';

class AppTheme {
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B34E8),
      Color(0xFF9B4DFF),
      Color(0xFFC76EFF),
    ],
  );

  static const secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFF8E8E),
      Color(0xFFFFB4B4),
    ],
  );

  static const successGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
  );

  static const errorGradient = LinearGradient(
    colors: [Color(0xFFD32F2F), Color(0xFFFF5252)],
  );

  static const backgroundColor = Color(0xFF0D0B1A);
  static const cardColor = Color(0xFF1A1730);
  static const surfaceColor = Color(0xFF26233D);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Poppins',
      primaryColor: Colors.deepPurple,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF9B4DFF),
        secondary: Color(0xFFC76EFF),
        surface: surfaceColor,
        background: backgroundColor,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
          borderSide: const BorderSide(color: Color(0xFF9B4DFF), width: 2),
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