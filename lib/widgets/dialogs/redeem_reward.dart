import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/storage/rewards.dart';
import 'package:couple_gacha/widgets/dialogs/gacha_dialog.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:couple_gacha/widgets/util/select_and_return_info.dart';
import 'package:flutter/material.dart';

class RedeemReward extends StatefulWidget {
  final int selectedRewardId;
  final int activePlayerId;

  const RedeemReward({
    super.key,
    required this.selectedRewardId,
    required this.activePlayerId,
  });

  static Future<bool?> open(
    BuildContext context,
    int activeChallengeId,
    int activePlayerId,
  ) {
    return GachaDialog.show<bool>(
      context,
      RedeemReward(
        selectedRewardId: activeChallengeId,
        activePlayerId: activePlayerId,
      ),
    );
  }

  @override
  State<RedeemReward> createState() => _RedeemRewardState();
}

class _RedeemRewardState extends State<RedeemReward> with RouteAware {
  StreamSubscription<NavInput>? _subscription;

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
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _inputProcessor(NavInput input) async {
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

    Reward selectedReward = RewardCatalog.getById(widget.selectedRewardId);

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
                  'Do you want to redeem this?',
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.6 * 0.08),
              child: Container(
                width: width,
                height: height * 0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: selectedReward.rarity.fillColor,
                  border: Border.all(
                    color: selectedReward.rarity.borderColor,
                    width: 5.0,
                  ),
                ),

                child: Align(
                  alignment: Alignment.center,
                  child: outlinedText(
                    selectedReward.text,
                    fontSize:
                        Theme.of(context).textTheme.labelMedium!.fontSize! *
                        fontScalingFactor,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    textColor: Theme.of(context).textTheme.labelMedium!.color!,
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.labelMedium!.fontFamily!,
                  ),
                ),
              ),
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
