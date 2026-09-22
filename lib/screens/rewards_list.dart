import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/storage/player_rewards.dart';
import 'package:couple_gacha/storage/rewards.dart';
import 'package:couple_gacha/widgets/rewards/redeem_challenge_element.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RewardsList extends StatefulWidget {
  const RewardsList({super.key});

  @override
  State<RewardsList> createState() => _RewardsListState();
}

class _RewardsListState extends State<RewardsList> with RouteAware {
  StreamSubscription<NavInput>? _subscription;
  bool _acceptsInput = true;

  int _highlightedElementIndex = 0;
  int _topRow = 1;
  int _bottomRow = 5;
  int _activeRow = 1;

  final int _rowCountToShow = 5;
  late double _rowHeight;

  final _rewardsOfActivePlayer = playerRewards[100] ?? <int, int>{};

  late final ScrollController _scrollController;

  void _scrollOneRow(double distance, ScrollDirection direction) {
    double endPosition = clampDouble(
      _scrollController.offset + distance,
      0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      endPosition,
      duration: Duration(milliseconds: 100),
      curve: Curves.linear,
    );

    if (direction == ScrollDirection.down) {
      _topRow--;
      _bottomRow--;
    } else {
      _topRow++;
      _bottomRow++;
    }
  }

  void _inputProcessor(NavInput event) {
    if (!_acceptsInput) return;
    if (!_scrollController.hasClients) return;

    switch (event) {

      case NavInput.up:

        if (_highlightedElementIndex == 0) return;

        setState(() {
          _highlightedElementIndex -= 2;
        });
        _activeRow--;

        if (_topRow != 1 && _activeRow == _topRow) {
          _scrollOneRow(-_rowHeight, ScrollDirection.down);
        }

        break;

      case NavInput.down:

        if (_rewardsOfActivePlayer.length - 1 == _highlightedElementIndex) return;

        setState(() {
          _highlightedElementIndex += 2;
        });

        _activeRow++;

        if (_scrollController.position.maxScrollExtent !=
                _scrollController.offset &&
            _bottomRow == _activeRow) {
          _scrollOneRow(_rowHeight, ScrollDirection.up);
        }

        break;

      case NavInput.left:

        if (_highlightedElementIndex == 0) return;

        if (_highlightedElementIndex % 2 == 0) _activeRow--;

        setState(() {
          _highlightedElementIndex -= 1;
        });

        if (_topRow != 1 && _activeRow == _topRow) {
          _scrollOneRow(-_rowHeight, ScrollDirection.down);
        }

        break;

      case NavInput.right:

        if (_rewardsOfActivePlayer.length - 1 == _highlightedElementIndex) return;

        if (_highlightedElementIndex != 0 && _highlightedElementIndex % 2 != 0) _activeRow++;

        setState(() {
          _highlightedElementIndex += 1;
        });

        if (_scrollController.position.maxScrollExtent !=
                _scrollController.offset &&
            _bottomRow == _activeRow) {
          _scrollOneRow(_rowHeight, ScrollDirection.up);
        }

        break;

      case NavInput.select:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NavInput.back:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    print('ActiveRow: $_activeRow, TopRow: $_topRow, BottomRow: $_bottomRow');
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

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

    _scrollController.dispose();

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
                _rowHeight = constraints.maxHeight / _rowCountToShow;

                final activePlayerRewardIds = _rewardsOfActivePlayer.keys
                    .toList();
                final activePlayerRewardAmounts = _rewardsOfActivePlayer.values
                    .toList();

                return GridView(
                  controller: _scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: _rowHeight,
                  ),
                  children: List.generate(_rewardsOfActivePlayer.length, (
                    index,
                  ) {
                    return buildRewardCell(
                      index,
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
    int index,
    int rewardId,
    int rewardAmount,
    double screenDiagonal,
    double width,
    double height
  ) {
    Reward rewardData = RewardCatalog.getById(rewardId);

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
      child: Row(
        children: [
          outlinedText(
            '${rewardAmount}x ',
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
              borderColor: index == _highlightedElementIndex ? Colors.white : rewardData.rarity.borderColor,
              fillColor: rewardData.rarity.fillColor,
              rotate: false,
            ),
          ),
        ],
      ),
    );
  }
}

// What direction the screen moves towards
enum ScrollDirection { up, down }
