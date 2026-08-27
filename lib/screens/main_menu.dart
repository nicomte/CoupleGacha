import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/domain/main_menu_enums.dart';
import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/screens/select_challenge.dart';
import 'package:couple_gacha/widgets/dialogs/auth_enums.dart';
import 'package:couple_gacha/widgets/dialogs/fingerprint_auth_dialog.dart';
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

class _MainMenuState extends State<MainMenu> with RouteAware {
  StreamSubscription<NavInput>? _subscription;
  DateTime? _lastInputTime;

  ({int menuOffset, RotationDirection rotationDirection}) _rotatingMenuData = (
    menuOffset: 0,
    rotationDirection: RotationDirection.clockwise,
  );

  int _activeChallenge = 0;
  ActiveMenu _activeMenu = ActiveMenu.rotatingMenu;
  double screenDiagonal = 0;
  bool _acceptsInput = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void didPushNext() => setState(() => _acceptsInput = false);

  @override
  void didPopNext() => setState(() => _acceptsInput = true);

  void _inputProcessor(NavInput input) {
    if (!_acceptsInput) return;

    final now = DateTime.now();

    if (_lastInputTime != null &&
        now.difference(_lastInputTime!) < const Duration(milliseconds: 400)) {
      return;
    }

    _lastInputTime = now;

    switch (input) {
      case NavInput.up:
        setState(() {
          if (_activeMenu == ActiveMenu.rotatingMenu) {
            _rotateMenu(direction: RotationDirection.counterClockwise);
          } else {
            _activeChallenge = _toggleActiveChallenge();
          }
        });
        break;

      case NavInput.down:
        setState(() {
          if (_activeMenu == ActiveMenu.rotatingMenu) {
            _rotateMenu(direction: RotationDirection.clockwise);
          } else {
            _activeChallenge = _toggleActiveChallenge();
          }
        });
        break;

      case NavInput.left:
        setState(() {
          _activeMenu = _toggleActiveMenu();
        });
        break;

      case NavInput.right:
        setState(() {
          _activeMenu = _toggleActiveMenu();
        });
        break;

      case NavInput.select:
        _select();
        break;

      case NavInput.back:
        // Can't cancel anything in here
        break;
    }
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
        _redeemChallenge();
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

  void _redeemChallenge() {
    // TODO: Implement redeemChallenge
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

  Future<void> _openSelectChallenge() async {
    final result = await showGeneralDialog<AuthResult>(
      context: context,
      pageBuilder: (c, a1, a2) => FingerprintAuthDialog(),
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 300),
      barrierDismissible: false,
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          Transform.scale(scale: animation.value, child: child),
    );

    if (!mounted) return;

    switch (result) {
      case null:
      // Nothing to do
      break;
      case AuthSuccess(:final userId):
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SelectChallenge(activePlayerId: userId),
          ),
        );
      case AuthCancelled():
      // Nothing to do
      break;
      case AuthFailed():
      // Nothing to do
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    screenDiagonal = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2));

    return Scaffold(
      body: Stack(
        children: [
          RotatingMenu(
            screenSize: screenSize,
            screenDiagonal: screenDiagonal,
            rotatingMenuData: _rotatingMenuData,
            activeMenu: _activeMenu,
          ),

          PointsOverview(
            screenSize: screenSize,
            screenDiagonal: screenDiagonal,
          ),

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
