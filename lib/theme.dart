import 'package:flutter/material.dart';

class AppTheme{
  static final ColorScheme _scheme = ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFFFF007F),
    onPrimary: Colors.black,
    primaryContainer: Color(0xFFFFD6E8),
    onPrimaryContainer: Color(0xFF4A0026),
    secondary: Color(0xFFD6879A) /* etc — fill in the roles you actually use */,
    onSecondary: Colors.white,
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    surface: Color(0xFFFFFBFE),
    onSurface: Color(0xFF1C1B1F)
  );
  static final ThemeData colorTheme = ThemeData(
    colorScheme: _scheme,
    scaffoldBackgroundColor: const Color.fromARGB(255, 214, 135, 174)
  );
}