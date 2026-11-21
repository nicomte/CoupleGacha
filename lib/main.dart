import 'dart:io';

import 'package:couple_gacha/navigation/composite_input_source.dart';
import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/navigation/keyboard_input_source.dart';
import 'package:couple_gacha/navigation/sensor_input_source.dart';
import 'package:couple_gacha/persistence_logic/persistence_init.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/screens/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:couple_gacha/theme.dart';

Future<void> main() async {
  await initPersistence(Directory('./stored_data'));
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final InputSource _inputSource;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _inputSource = CompositeInputSource([
      KeyboardInputSource(),
      SensorInputSource(_navigatorKey),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return InputSourceProvider(
      inputSource: _inputSource,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        theme: AppTheme.colorTheme,
        navigatorObservers: [routeObserver],
        home: const MainMenu(),
      ),
    );
  }
}
