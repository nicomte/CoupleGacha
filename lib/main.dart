import 'dart:io';

import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/navigation/keyboard_input_source.dart';
import 'package:couple_gacha/persistence_logic/persistence_init.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/screens/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:couple_gacha/theme.dart';

void main() {
  initPersistence(Directory('./stored_data'));
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return InputSourceProvider(
      inputSource: KeyboardInputSource(),
      child: MaterialApp(
        theme: AppTheme.colorTheme,
        navigatorObservers: [routeObserver],
        home: InputSourceProvider(
          inputSource: KeyboardInputSource(),
          child: MainMenu(),
        ),
      ),
    );
  }
}
