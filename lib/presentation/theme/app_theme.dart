import 'package:flutter/material.dart';

/// App theme configuration
class AppTheme {
  /// Private constructor to prevent instantiation
  const AppTheme._();

  // Brand colors
  static const Color _primaryColor = Color(0xFF2E7D32); // Green 800
  static const Color _secondaryColor = Color(0xFF00796B); // Teal 700
  static const Color _errorColor = Color(0xFFD32F2F); // Red 700
  
  // Text colors
  static const Color _darkTextColor = Color(0xFF212121); // Grey 900
  static const Color _lightTextColor = Color(0xFFFAFAFA); // Grey 50
  
  // Background colors
  static const Color _lightBackgroundColor = Color(0xFFFAFAFA); // Grey 50
  static const Color _darkBackgroundColor = Color(0xFF121212); // Material dark background

  /// Light theme configuration
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
      error: _errorColor,
      onPrimary: _lightTextColor,
      onSecondary: _lightTextColor,
      onError: _lightTextColor,
      background: _lightBackgroundColor,
      surface: Colors.white,
      onBackground: _darkTextColor,
      onSurface: _darkTextColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: _lightTextColor,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _lightTextColor,
        backgroundColor: _primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: const BorderSide(color: _primaryColor),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: _lightTextColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0), // Grey 300
      thickness: 1,
      space: 1,
    ),
    scaffoldBackgroundColor: _lightBackgroundColor,
  );

  /// Dark theme configuration
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _primaryColor.withOpacity(0.8), // Slightly muted for dark theme
      secondary: _secondaryColor.withOpacity(0.8),
      error: _errorColor.withOpacity(0.8),
      onPrimary: _lightTextColor,
      onSecondary: _lightTextColor,
      onError: _lightTextColor,
      background: _darkBackgroundColor,
      surface: const Color(0xFF1E1E1E), // Slightly lighter than background
      onBackground: _lightTextColor,
      onSurface: _lightTextColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkBackgroundColor,
      foregroundColor: _lightTextColor,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF2C2C2C), // Slightly lighter than surface
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _lightTextColor,
        backgroundColor: _primaryColor.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryColor.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: _primaryColor.withOpacity(0.8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor.withOpacity(0.8),
      foregroundColor: _lightTextColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _primaryColor.withOpacity(0.8), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _errorColor.withOpacity(0.8), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      fillColor: const Color(0xFF2C2C2C),
      filled: true,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF424242), // Grey 800
      thickness: 1,
      space: 1,
    ),
    scaffoldBackgroundColor: _darkBackgroundColor,
  );
}
