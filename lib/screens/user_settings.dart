import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/storage/player_rewards.dart';
import 'package:couple_gacha/storage/players.dart';
import 'package:couple_gacha/widgets/user_settings/fingerprint_enrollment_dialog.dart';
import 'package:couple_gacha/widgets/user_settings/user_element.dart';
import 'package:couple_gacha/widgets/user_settings/user_name_input_widget.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:couple_gacha/widgets/util/select_and_return_info.dart';
import 'package:flutter/material.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> with RouteAware {
  static const int _maxPlayers = 2;

  StreamSubscription<NavInput>? _subscription;
  bool _acceptsInput = true;

  /// True while the add-player flow is running, so extra inputs are ignored.
  bool _busy = false;

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
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() => setState(() => _acceptsInput = false);

  @override
  void didPopNext() => setState(() => _acceptsInput = true);

  Future<void> _inputProcessor(NavInput input) async {
    if (!_acceptsInput || _busy) return;

    switch (input) {
      case NavInput.back:
        Navigator.of(context).pop();
      case NavInput.select:
        await _addPlayer();
      case NavInput.up:
      case NavInput.down:
      case NavInput.left:
      case NavInput.right:
        break;
    }
  }

  Future<void> _addPlayer() async {
  if (playerStore.players.length >= _maxPlayers) return;

  _busy = true;
  try {
    final userName = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const UserNameInputWidget()),
    );
    final trimmedName = userName?.trim() ?? '';
    if (trimmedName.isEmpty || !mounted) return;

    final userId = await FingerprintEnrollmentDialog.open(
      context,
      dialogText: 'Press finger firmly onto the sensor, cover it as much as possible and don\'t move'
    );

    // null = failed or cancelled; the dialog already told the user why.
    if (userId == null || !mounted) return;

    playerStore.addPlayer(Player(playerId: userId, playerName: trimmedName));
    playerRewards[userId] = {};
    setState(() {});
  } finally {
    _busy = false;
  }
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(size.width * size.width + size.height * size.height);
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium!;
    final canAddPlayer = playerStore.players.length < _maxPlayers;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: outlinedText(
              'Registered Players:',
              fontSize: screenDiagonal * 0.08,
              backgroundColor: theme.colorScheme.tertiary,
              textColor: bodyStyle.color!,
              fontFamily: bodyStyle.fontFamily!,
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenDiagonal * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final player in playerStore.players)
                    UserElement(
                      userName: player.playerName,
                      screenDiagonal: screenDiagonal,
                      screenWidth: size.width,
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: canAddPlayer
                ? SelectAndReturnInfo.twoOptions(
                    firstButtonAsset: 'assets/green_button.svg',
                    firstActionText: 'to add player',
                    secondButtonAsset: 'assets/red_button.svg',
                    secondActionText: 'to return',
                  )
                : SelectAndReturnInfo.singleOption(
                    buttonAsset: 'assets/red_button.svg',
                    actionText: 'to return',
                  ),
          ),
        ],
      ),
    );
  }
}