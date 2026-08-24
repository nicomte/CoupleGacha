import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/navigation/keyboard_input_source.dart';
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
    home: InputSourceProvider(
      inputSource: KeyboardInputSource(),
      child: const MainMenu(),
    ),
  );
}
