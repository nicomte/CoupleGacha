import 'package:couple_gacha/screens/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:couple_gacha/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      theme: AppTheme.colorTheme,
      home: const MainMenu(),
    );
  
}
