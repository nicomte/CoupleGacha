import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/domain/auth_enums.dart';
import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/storage/active_challenges.dart';
import 'package:couple_gacha/storage/challenges.dart';
import 'package:couple_gacha/storage/players.dart';
import 'package:couple_gacha/widgets/dialogs/fingerprint_auth_dialog.dart';
import 'package:couple_gacha/widgets/dialogs/gacha_dialog.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:couple_gacha/widgets/util/select_and_return_info.dart';
import 'package:couple_gacha/widgets/util/warning_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ConfirmChallengeSuccess extends StatefulWidget {
  final int activeChallengeId;
  final int activePlayerId;

  const ConfirmChallengeSuccess({
    super.key,
    required this.activeChallengeId,
    required this.activePlayerId,
  });

  static Future<bool?> open(
    BuildContext context,
    int activeChallengeId,
    int activePlayerId,
  ) {
    return GachaDialog.show<bool>(
      context,
      ConfirmChallengeSuccess(
        activeChallengeId: activeChallengeId,
        activePlayerId: activePlayerId,
      ),
    );
  }

  @override
  State<ConfirmChallengeSuccess> createState() =>
      _ConfirmChallengeSuccessState();
}

class _ConfirmChallengeSuccessState extends State<ConfirmChallengeSuccess>
    with RouteAware {
  StreamSubscription<NavInput>? _subscription;

  bool _acceptsInput = true;

  @override
  void didPushNext() => setState(() => _acceptsInput = false);

  @override
  void didPopNext() => setState(() => _acceptsInput = true);

  @override
  void didChangeDependencies() {
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);

    routeObserver.subscribe(this, ModalRoute.of(context)!);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_subscription != null) _subscription!.cancel();
    super.dispose();
  }

  void _awardPoints() {
    final activePlayerIndex = players.indexWhere(
      (player) => player.playerId == widget.activePlayerId,
    );

    players[activePlayerIndex].addPoints(
      challenges.firstWhere((c) => c.challengeId == widget.activeChallengeId).challengePoints,
    );
  }

  void _updateActiveChallenge() {
    activeChallenges.remove(activeChallenges.entries.toList().firstWhere((c)=> c.value == widget.activeChallengeId).key);
  }

  Future<void> _inputProcessor(NavInput input) async {
    if (!_acceptsInput) return;
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
        final result = await FingerprintAuthDialog.open(context, dialogText: 'Put partners finger on sensor to confirm.');

        switch (result) {
          case null:
            // Nothing to do
            break;

          case AuthSuccess(:final userId):
            if (userId == widget.activePlayerId) {
              if (!mounted) return;
              WarningPopup.show(
                context,
                'This was the wrong persons finger.',
                Duration(seconds: 3),
              );
              break;
            } else {
              _awardPoints();
              _updateActiveChallenge();

              await Future.delayed(const Duration(seconds: 1));

              if (!mounted) return;
              Navigator.of(context).pop(true);
              return;
            }

          case AuthCancelled():
            // Nothing to do
            break;

          case AuthFailed():
            // Nothing to do
            break;
        }

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
                  'Mark this challenge as finished?',
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
                        challenges
                            .firstWhere(
                              (c) => c.challengeId == widget.activeChallengeId,
                            )
                            .challengeText,
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
            SelectAndReturnInfo.twoOptions(
              firstButtonAsset: 'assets/green_button.svg',
              firstActionText: 'to confirm',
              secondButtonAsset: 'assets/red_button.svg',
              secondActionText: 'to cancel',
            ),
          ],
        );
      },
    );
  }
}
