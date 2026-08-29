import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/storage/active_challenges.dart';
import 'package:couple_gacha/storage/challenges.dart';
import 'package:couple_gacha/widgets/dialogs/gacha_dialog.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:couple_gacha/widgets/util/select_and_return_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RevealChallenge extends StatefulWidget {
  final Challenge challenge;
  final int activePlayerId;

  const RevealChallenge({super.key, required this.challenge, required this.activePlayerId});

  static Future<void> open(BuildContext context, Challenge challengeId, int activePlayerId) {
    return GachaDialog.show<void>(
      context,
      RevealChallenge(challenge: challengeId, activePlayerId: activePlayerId,),
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
      duration: Duration(seconds: 2),
    )..forward();

    _angle = Tween<double>(
      begin: 0,
      end: 5 * 2 * pi + pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
    if (_subscription == null) return;
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
      activeChallenges[widget.activePlayerId] = widget.challenge.challengeText;
        Navigator.of(context).pop(true);
        break;
      case NavInput.back:
        // Nothing to do
        break;
    }
  }

  double _getNormalizedAngle(double angle){
    return angle % (2*pi);
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
                child:
                    _getNormalizedAngle(_angle.value) >= pi / 2 && _getNormalizedAngle(_angle.value) <= 1.5 * pi ||
                        _angle.isCompleted
                    ? Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          SvgPicture.asset(
                            'assets/challenge_text_reveal_card.svg',
                            height: height * 0.7,
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.7 * 0.08,
                              ),
                              child: Center(
                                child: Transform.flip(
                                  flipX: true,
                                  child: outlinedText(
                                    widget.challenge.challengeText,
                                    fontSize:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.fontSize! *
                                        fontScalingFactor,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                    textColor: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color!,
                                    fontFamily: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.fontFamily!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SvgPicture.asset(
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
