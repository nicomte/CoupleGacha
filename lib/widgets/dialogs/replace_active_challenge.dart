import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/storage/active_challenges.dart';
import 'package:couple_gacha/widgets/dialogs/gacha_dialog.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:couple_gacha/widgets/util/select_and_return_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReplaceActiveChallenge extends StatefulWidget {
  final dynamic activeChallengeId;

  const ReplaceActiveChallenge({super.key, required this.activeChallengeId});

  static Future<bool?> open(BuildContext context, int activeChallengeId) {
    return GachaDialog.show<bool>(
      context,
      ReplaceActiveChallenge(activeChallengeId: activeChallengeId),
    );
  }

  @override
  State<StatefulWidget> createState() => _ReplaceActiveChallengeState();
}

class _ReplaceActiveChallengeState extends State<ReplaceActiveChallenge> {
  StreamSubscription<NavInput>? _subscription;

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
        Navigator.of(context).pop(true);
        break;
      case NavInput.back:
        Navigator.of(context).pop(false);
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.6 * 0.08),
              child: FittedBox(
                fit: BoxFit.contain,
                child: outlinedText(
                  'You already have an active challenge: ',
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium!.fontSize! *
                      fontScalingFactor,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).textTheme.headlineMedium!.color!,
                  fontFamily: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontFamily!,
                ),
              ),
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                SvgPicture.asset(
                  'assets/challenge_text_reveal_card.svg',
                  height: height * 0.6,
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.6 * 0.08,
                    ),
                    child: Center(
                      child: outlinedText(
                        activeChallenges[widget.activeChallengeId]!,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize! *
                            fontScalingFactor,
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
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
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.6 * 0.08),
              child: FittedBox(
                fit: BoxFit.contain,
                child: outlinedText(
                  'Would you like to replace it?',
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium!.fontSize! *
                      fontScalingFactor,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).textTheme.headlineMedium!.color!,
                  fontFamily: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontFamily!,
                ),
              ),
            ),
            SelectAndReturnInfo.twoOptions(
              firstButtonAsset: 'assets/green_button.svg',
              firstActionText: 'to replace',
              secondButtonAsset: 'assets/red_button.svg',
              secondActionText: 'to cancel',
            ),
          ],
        );
      },
    );
  }
}
