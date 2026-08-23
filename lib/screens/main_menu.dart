import 'dart:async';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/keyboard_input_source.dart';
import 'package:couple_gacha/widgets/main_menu/challenge_list/challenges_list.dart';
import 'package:couple_gacha/widgets/main_menu/points_overview.dart';
import 'package:couple_gacha/widgets/main_menu/rotating_menu.dart';
import 'package:couple_gacha/widgets/util/assets_index.dart';
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

  // rotationDirection 1 = forwards, -1 = backwards
  ({int menuOffset, int rotationDirection}) _rotatingMenuData = (menuOffset: 0, rotationDirection: 1);

  int _activeChallenge = 0;
  int _activeMenu = 0;

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
          _rotatingMenuData = (menuOffset: (_rotatingMenuData.menuOffset + 1) % AssetsIndex.menuAssetPaths.length, rotationDirection: -1);
          break;
        case NavInput.down:
          _rotatingMenuData = (menuOffset: (_rotatingMenuData.menuOffset - 1) % AssetsIndex.menuAssetPaths.length, rotationDirection: 1);
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(
      pow(screenSize.width, 2) + pow(screenSize.height, 2),
    );
    return Scaffold(
      body: Stack(
        children: [
          RotatingMenu(screenSize: screenSize, screenDiagonal: screenDiagonal, rotatingMenuData: _rotatingMenuData, activeMenu: _activeMenu),
          PointsOverview(
            screenSize: screenSize
          ),
          ChallengesList(screenSize: screenSize, activeChallenge: _activeChallenge, activeMenu: _activeMenu)
        ],
      ),
    );
  }
}
