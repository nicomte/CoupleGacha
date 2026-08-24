import 'dart:async';
import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/widgets/main_menu/challenge_list/challenges_list.dart';
import 'package:couple_gacha/widgets/main_menu/main_menu_enums.dart';
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

  StreamSubscription<NavInput>? _subscription;

  ({int menuOffset, RotationDirection rotationDirection}) _rotatingMenuData = (
    menuOffset: 0,
    rotationDirection: RotationDirection.clockwise,
  );

  int _activeChallenge = 0;
  ActiveMenu _activeMenu = ActiveMenu.rotatingMenu;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(_subscription == null, 'MainMenu is already subscribed to InputSource');
    _subscription = InputSourceProvider.of(context).inputSource.events.listen(_inputProcessor);
  }

  void _inputProcessor(NavInput input) {
    setState(() {
      switch (input) {
        case NavInput.up:
          if (_activeMenu == ActiveMenu.rotatingMenu) {
            _rotatingMenuData = (
              menuOffset:
                  (_rotatingMenuData.menuOffset + 1) %
                  AssetsIndex.menuAssetPaths.length,
              rotationDirection: RotationDirection.counterClockwise,
            );
          } else {
            _activeChallenge = _toggleActiveChallenge();
          }
          break;

        case NavInput.down:
          if (_activeMenu == ActiveMenu.rotatingMenu) {
            _rotatingMenuData = (
              menuOffset:
                  (_rotatingMenuData.menuOffset - 1) %
                  AssetsIndex.menuAssetPaths.length,
              rotationDirection: RotationDirection.clockwise,
            );
          } else {
            _activeChallenge = _toggleActiveChallenge();
          }
          break;

        case NavInput.left:
          _activeMenu = _toggleActiveMenu();
          break;
        case NavInput.right:
          _activeMenu = _toggleActiveMenu();
          break;
        case NavInput.select:
          break;
        case NavInput.back:
          break;
      }
    });
  }

  ActiveMenu _toggleActiveMenu() {
    return _activeMenu == ActiveMenu.rotatingMenu
        ? ActiveMenu.challengesList
        : ActiveMenu.rotatingMenu;
  }

  int _toggleActiveChallenge() {
    return _activeChallenge == 0 ? 1 : 0;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
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
          RotatingMenu(
            screenSize: screenSize,
            screenDiagonal: screenDiagonal,
            rotatingMenuData: _rotatingMenuData,
            activeMenu: _activeMenu,
          ),
          PointsOverview(screenSize: screenSize),
          ChallengesList(
            screenSize: screenSize,
            activeChallenge: _activeChallenge,
            activeMenu: _activeMenu,
          ),
        ],
      ),
    );
  }
}
