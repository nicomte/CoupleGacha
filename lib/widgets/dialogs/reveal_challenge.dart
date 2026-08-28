import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/storage/challenges.dart';
import 'package:couple_gacha/widgets/dialogs/gacha_dialog.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:couple_gacha/widgets/util/select_and_return_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RevealChallenge extends StatefulWidget {
  final Challenge challenge;

  const RevealChallenge({super.key, required this.challenge});

  static Future<void> open(BuildContext context, Challenge challengeId) {
    return GachaDialog.show<void>(
      context,
      RevealChallenge(challenge: challengeId),
    );
  }

  @override
  State<StatefulWidget> createState() => _RevealChallengeState();
}

class _RevealChallengeState extends State<RevealChallenge>
    with TickerProviderStateMixin {
  StreamSubscription<NavInput>? _subscription;
  late final AnimationController _controller;
  late final Animation<double> _angle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..repeat();

    _angle = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_subscription != null) _subscription!.cancel();
    super.dispose();
  }

  void _inputProcessor(NavInput input) {
    switch (input) {
      case NavInput.up:
        // Nothing to do
        break;
      case NavInput.down:
        // Nothing to do
        break;
      case NavInput.left:
        // Nothing to do
        break;
      case NavInput.right:
        // Nothing to do
        break;
      case NavInput.select:
        Navigator.of(context).pop();
      case NavInput.back:
        // Nothing to do
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final fontScalingFactor = sqrt(pow(width, 2) + pow(height, 2)) * 0.001;

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            outlinedText(
              'Your challenge is',
              fontSize:
                  Theme.of(context).textTheme.headlineMedium!.fontSize! *
                  fontScalingFactor,
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              textColor: Theme.of(context).textTheme.headlineMedium!.color!,
              fontFamily: Theme.of(
                context,
              ).textTheme.headlineMedium!.fontFamily!,
            ),
            AnimatedBuilder(
              animation: _angle,
              builder: (context, child) => Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_angle.value),
                alignment: FractionalOffset.center,
                child: SvgPicture.asset(
                  'assets/challenge_reveal_card.svg',
                  height: height * 0.7,
                ),
              ),
            ),
            SelectAndReturnInfo.singleOption(
              buttonAsset: 'assets/green_button.svg',
              actionText: 'to close.',
            ),
          ],
        );
      },
    );
  }
}
