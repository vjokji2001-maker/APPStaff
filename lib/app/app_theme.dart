import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const primaryColor = Color(0xFF1A237E);

  static ThemeData buildTheme(bool isDark, double fontSize) {
    final textTheme = const TextTheme(
      displayLarge: TextStyle(fontSize: 34),
      displayMedium: TextStyle(fontSize: 30),
      displaySmall: TextStyle(fontSize: 26),
      headlineLarge: TextStyle(fontSize: 24),
      headlineMedium: TextStyle(fontSize: 22),
      headlineSmall: TextStyle(fontSize: 20),
      titleLarge: TextStyle(fontSize: 18),
      titleMedium: TextStyle(fontSize: 16),
      titleSmall: TextStyle(fontSize: 15),
      bodyLarge: TextStyle(fontSize: 18),
      bodyMedium: TextStyle(fontSize: 16),
      bodySmall: TextStyle(fontSize: 14),
      labelLarge: TextStyle(fontSize: 16),
      labelMedium: TextStyle(fontSize: 14),
      labelSmall: TextStyle(fontSize: 13),
    );

    const appBarOverlay = AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    if (isDark) {
      return ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: Color(0xFF00C897),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintStyle: TextStyle(color: Colors.grey[400]),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[600]!),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF90CAF9), width: 2),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF90CAF9),
          selectionColor: Color(0x4490CAF9),
          selectionHandleColor: Color(0xFF90CAF9),
        ),
        appBarTheme: appBarOverlay.copyWith(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        textTheme: textTheme,
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) =>
                s.contains(WidgetState.selected) ? primaryColor : Colors.grey,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: Color(0xFF00C897),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      cardColor: Colors.white,
      appBarTheme: appBarOverlay.copyWith(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      textTheme: textTheme,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primaryColor : Colors.grey,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
