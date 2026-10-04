import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/fingerprint_scanner_isolate/sensor_service.dart';
import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/storage/players.dart';
import 'package:couple_gacha/widgets/user_settings/user_element.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:couple_gacha/widgets/util/select_and_return_info.dart';

import 'package:flutter/material.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> with RouteAware {
  StreamSubscription<NavInput>? _subscription;
  //late final SensorService _sensorService;

  bool _acceptsInput = true;

  @override
  void initState() {
    //_sensorService = SensorService();
    //_sensorService.init();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void didPushNext() => setState(() => _acceptsInput = false);

  @override
  void didPopNext() => setState(() => _acceptsInput = true);

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription!.cancel();
    }
    routeObserver.unsubscribe(this);
    //_sensorService.dispose();
    super.dispose();
  }

  Future<void> _inputProcessor(NavInput input) async {
    if (!_acceptsInput) return;

    switch (input) {
      case NavInput.back:
        Navigator.of(context).pop();
        break;
      case NavInput.up:
      case NavInput.down:
        // Nothing to do
        break;
      case NavInput.left:
        break;
      case NavInput.right:
        break;
      case NavInput.select:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenDiagonal = sqrt(
      pow(MediaQuery.of(context).size.height, 2) +
          pow(MediaQuery.of(context).size.width, 2),
    );

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: outlinedText(
              'Registered Players:',
              fontSize: screenDiagonal * 0.08,
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              textColor: Theme.of(context).textTheme.bodyMedium!.color!,
              fontFamily: Theme.of(context).textTheme.bodyMedium!.fontFamily!,
            ),
          ),

          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: screenDiagonal * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (Player p in playerStore.players)
                    UserElement(
                      userName: p.playerName,
                      screenDiagonal: screenDiagonal,
                      screenWidth: screenWidth,
                    ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: playerStore.players.length < 2
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
