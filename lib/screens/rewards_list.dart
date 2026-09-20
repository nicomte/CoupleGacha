import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/storage/player_rewards.dart';
import 'package:couple_gacha/storage/rewards.dart';
import 'package:couple_gacha/widgets/rewards/redeem_challenge_element.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';

class RewardsList extends StatefulWidget {
  const RewardsList({super.key});

  @override
  State<RewardsList> createState() => _RewardsListState();
}

class _RewardsListState extends State<RewardsList> with RouteAware {
  StreamSubscription<NavInput>? _subscription;
  bool _acceptsInput = true;

  void _inputProcessor(NavInput event) {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPushNext() => setState(() => _acceptsInput = false);

  @override
  void didPopNext() => setState(() => _acceptsInput = true);

  @override
  void dispose() {
    if (_subscription != null) _subscription!.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(
      pow(screenSize.width, 2) + pow(screenSize.height, 2),
    );
    final columnWidth = screenSize.width / 2;

    final fontScalingFactor = screenDiagonal * 0.001;

    final rewardsOfActivePlayer = playerRewards[100] ?? <int, int>{};

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: outlinedText(
              'Your Rewards',
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
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {

                final activePlayerRewardIds = rewardsOfActivePlayer.keys.toList();
                final activePlayerRewardAmounts = rewardsOfActivePlayer.values.toList();
                return GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: constraints.maxHeight / 5,
                  ),
                  children: List.generate(rewardsOfActivePlayer.length, (
                    index,
                  ) {
                    return buildRewardCell(
                      activePlayerRewardIds[index],
                      activePlayerRewardAmounts[index],
                      screenDiagonal,
                      columnWidth,
                      constraints.maxHeight / 7,
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRewardCell(
    int rewardId,
    int rewardAmount,
    double screenDiagonal,
    double width,
    double height,
  ) {
    Reward rewardData = RewardCatalog.getById(rewardId);

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
      child: Row(
        children: [
          outlinedText(
            '${rewardAmount}x',
            fontSize:
                Theme.of(context).textTheme.bodyMedium!.fontSize! *
                screenDiagonal *
                0.001,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            textColor: Theme.of(context).textTheme.bodyMedium!.color!,
            fontFamily: Theme.of(context).textTheme.bodyMedium!.fontFamily!,
          ),
          Expanded(
            child: RedeemChallengeElement(
              rewardText: rewardData.text,
              screenDiagonal: screenDiagonal,
              width: width,
              height: height,
              borderColor: rewardData.rarity.borderColor,
              fillColor: rewardData.rarity.fillColor,
              rotate: false,
            ),
          ),
        ],
      ),
    );
  }
}
