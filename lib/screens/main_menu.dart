import 'dart:async';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/keyboard_input_source.dart';
import 'package:couple_gacha/widgets/main_menu/challenge_list/challenges_list.dart';
import 'package:couple_gacha/widgets/main_menu/points_overview.dart';
import 'package:couple_gacha/widgets/main_menu/rotating_menu.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {

  late final InputSource _inputSource;
  StreamSubscription<NavInput>? _subscription;
  final int _rotatingOffset = 0;
  final int _activeChallenge = 0;
  final int _activeMenu = 0;

/*
  @override
  void initState(){
    super.initState();
    _inputSource = KeyboardInputSource();
    _subscription = _inputSource.events.listen(inputProcessor);
  }

  void inputProcessor(NavInput input) {
    setState(() {
      switch (input){
        case NavInput.up:
          (_rotatingOffset + 1) % RotatingMenu._menuAssetPaths.length;
          break;
        case NavInput.down:
          (_rotatingOffset - 1) % RotatingMenu._menuAssetPaths.length;
          break;
        case NavInput.left:
          break;
        case NavInput.right:
          break;
        case NavInput.select:
          break;
        case NavInput.back:
          break;
      }
    });
  }
*/
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(
      pow(screenSize.width, 2) + pow(screenSize.height, 2),
    );
    return Scaffold(
      body: Stack(
        children: [
          RotatingMenu(screenSize: screenSize, screenDiagonal: screenDiagonal, rotatingOffset: _rotatingOffset, activeMenu: _activeMenu),
          PointsOverview(
            screenSize: screenSize
          ),
          ChallengesList(screenSize: screenSize, activeChallenge: _activeChallenge, activeMenu: _activeMenu)
        ],
      ),
    );
  }
}
