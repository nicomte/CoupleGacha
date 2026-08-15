import 'package:flutter/material.dart';

class AppTheme{
  static final ColorScheme _scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFFF007F),
    brightness: Brightness.light, // or Brightness.dark
  );
  static final ThemeData colorTheme = ThemeData(
    colorScheme: _scheme,
    scaffoldBackgroundColor: const Color.fromARGB(255, 214, 135, 174), // <-- this is the key line
  );
}