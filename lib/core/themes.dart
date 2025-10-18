import 'package:flutter/material.dart';

class AppThemes {
  // Primary color palette for the power management app
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF1E88E5,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF2196F3),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySwatch,
      brightness: Brightness.light,
    ),
    // Increase text sizes globally by adding 2-3 points to each style
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 59),   // default: 57
      displayMedium: TextStyle(fontSize: 47),  // default: 45
      displaySmall: TextStyle(fontSize: 38),   // default: 36
      headlineLarge: TextStyle(fontSize: 34),  // default: 32
      headlineMedium: TextStyle(fontSize: 30), // default: 28
      headlineSmall: TextStyle(fontSize: 26),  // default: 24
      titleLarge: TextStyle(fontSize: 24),     // default: 22
      titleMedium: TextStyle(fontSize: 18),    // default: 16
      titleSmall: TextStyle(fontSize: 16),     // default: 14
      bodyLarge: TextStyle(fontSize: 18),      // default: 16
      bodyMedium: TextStyle(fontSize: 16),     // default: 14
      bodySmall: TextStyle(fontSize: 14),      // default: 12
      labelLarge: TextStyle(fontSize: 16),     // default: 14 (buttons)
      labelMedium: TextStyle(fontSize: 14),    // default: 12
      labelSmall: TextStyle(fontSize: 13),     // default: 11
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 4,
      backgroundColor: Color(0xFF283593), // Deep indigo blue for light theme
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: primarySwatch.shade300,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: primarySwatch,
          width: 2,
        ),
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySwatch,
      brightness: Brightness.dark,
    ),
    // Increase text sizes globally by adding 2-3 points to each style
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 59),   // default: 57
      displayMedium: TextStyle(fontSize: 47),  // default: 45
      displaySmall: TextStyle(fontSize: 38),   // default: 36
      headlineLarge: TextStyle(fontSize: 34),  // default: 32
      headlineMedium: TextStyle(fontSize: 30), // default: 28
      headlineSmall: TextStyle(fontSize: 26),  // default: 24
      titleLarge: TextStyle(fontSize: 24),     // default: 22
      titleMedium: TextStyle(fontSize: 18),    // default: 16
      titleSmall: TextStyle(fontSize: 16),     // default: 14
      bodyLarge: TextStyle(fontSize: 18),      // default: 16
      bodyMedium: TextStyle(fontSize: 16),     // default: 14
      bodySmall: TextStyle(fontSize: 14),      // default: 12
      labelLarge: TextStyle(fontSize: 16),     // default: 14 (buttons)
      labelMedium: TextStyle(fontSize: 14),    // default: 12
      labelSmall: TextStyle(fontSize: 13),     // default: 11
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 4,
      backgroundColor: Color(0xFF1E1E1E), // Lighter shade of black for dark theme
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: primarySwatch.shade300,
          width: 2,
        ),
      ),
    ),
  );
}
