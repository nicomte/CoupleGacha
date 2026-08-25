import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/domain/main_menu_enums.dart';
import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/widgets/main_menu/challenge_list/challenges_list.dart';
import 'package:couple_gacha/widgets/main_menu/points_overview.dart';
import 'package:couple_gacha/widgets/main_menu/rotating_menu/assets_index.dart';
import 'package:couple_gacha/widgets/main_menu/rotating_menu/rotating_menu.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  StreamSubscription<NavInput>? _subscription;
  DateTime? _lastInputTime;

  ({int menuOffset, RotationDirection rotationDirection}) _rotatingMenuData = (
    menuOffset: 0,
    rotationDirection: RotationDirection.clockwise,
  );

  int _activeChallenge = 0;

  ActiveMenu _activeMenu = ActiveMenu.rotatingMenu;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    assert(
      _subscription == null,
      'MainMenu is already subscribed to InputSource',
    );

    _subscription = InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);
  }

  void _inputProcessor(NavInput input) {
    final now = DateTime.now();

    if (_lastInputTime != null &&
        now.difference(_lastInputTime!) < const Duration(milliseconds: 400)) {
      return;
    }

    _lastInputTime = now;

    setState(() {
      switch (input) {
        case NavInput.up:
          if (_activeMenu == ActiveMenu.rotatingMenu) {
            _rotateMenu(direction: RotationDirection.counterClockwise);
          } else {
            _activeChallenge = _toggleActiveChallenge();
          }
          break;

        case NavInput.down:
          if (_activeMenu == ActiveMenu.rotatingMenu) {
            _rotateMenu(direction: RotationDirection.clockwise);
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
          _select();
          break;

        case NavInput.back:
          break;
      }
    });
  }

  void _rotateMenu({required RotationDirection direction}) {
    final length = AssetsIndex.menuItems.length;

    final newOffset = direction == RotationDirection.counterClockwise
        ? (_rotatingMenuData.menuOffset + 1) % length
        : (_rotatingMenuData.menuOffset - 1) % length;

    _rotatingMenuData = (menuOffset: newOffset, rotationDirection: direction);
  }

  ActiveMenu _toggleActiveMenu() {
    return _activeMenu == ActiveMenu.rotatingMenu
        ? ActiveMenu.challengesList
        : ActiveMenu.rotatingMenu;
  }

  int _toggleActiveChallenge() {
    return _activeChallenge == 0 ? 1 : 0;
  }

  /// Returns the menu item currently positioned to the right of the
  /// rotating menu's center.
  ///
  /// Position 0 = top
  /// Position 1 = right
  /// Position 2 = bottom
  /// Position 3 = left
  MainMenuItem _activeRotatingMenuItem() {
    const rightPosition = 1;

    final index =
        (rightPosition + _rotatingMenuData.menuOffset) %
        AssetsIndex.menuItems.length;

    return AssetsIndex.menuItems[index];
  }

  void _select() {
    switch (_activeMenu) {
      case ActiveMenu.rotatingMenu:
        _selectRotatingMenuItem();
        break;

      case ActiveMenu.challengesList:
        _selectChallenge();
        break;
    }
  }

  void _selectRotatingMenuItem() {
    final menuItem = _activeRotatingMenuItem();

    switch (menuItem) {
      case MainMenuItem.checkRewards:
        _openCheckRewards();
        break;

      case MainMenuItem.playerSettings:
        _openPlayerSettings();
        break;

      case MainMenuItem.redeemPoints:
        _openRedeemPoints();
        break;

      case MainMenuItem.selectChallenge:
        _openSelectChallenge();
        break;
    }
  }

  void _selectChallenge() {
    // TODO: Handle selecting a challenge.
  }

  void _openCheckRewards() {
    // TODO: Navigate to check rewards.
    //
    // Example:
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => const CheckRewardsScreen(),
    //   ),
    // );
  }

  void _openPlayerSettings() {
    // TODO: Navigate to player settings.
  }

  void _openRedeemPoints() {
    // TODO: Navigate to redeem points.
  }

  void _openSelectChallenge() {
    // TODO: Navigate to challenge selection.
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
