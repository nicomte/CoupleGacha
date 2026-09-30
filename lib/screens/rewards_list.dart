import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/storage/player_rewards.dart';
import 'package:couple_gacha/storage/rewards.dart';
import 'package:couple_gacha/widgets/dialogs/redeem_reward.dart';
import 'package:couple_gacha/widgets/rewards/reward_element.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RewardsList extends StatefulWidget {
  final int activePlayerId;

  const RewardsList({super.key, required this.activePlayerId});

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

  late Map<int, int> _rewardsOfActivePlayer;
  late List<int> _activePlayerRewardIds;

  late final ScrollController _scrollController;

  // Per-cell highlight notifiers. Changing highlight only notifies two cells
  // instead of rebuilding the whole grid.
  late List<ValueNotifier<bool>> _highlightNotifiers;

  // Cached theme values — same for every cell, so no per-cell Theme.of().
  late double _headlineFontSize;
  late double _bodyFontSize;
  late Color _tertiaryColor;
  late Color _bodyTextColor;
  late String? _headlineFontFamily;
  late String? _bodyFontFamily;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _rewardsOfActivePlayer = playerRewards[widget.activePlayerId] ?? <int, int>{};
    _activePlayerRewardIds = _rewardsOfActivePlayer.keys.toList();
    _highlightNotifiers = List.generate(
      _activePlayerRewardIds.length,
      (i) => ValueNotifier<bool>(i == 0),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscription ??= InputSourceProvider.of(context).inputSource.events.listen(_inputProcessor);

    final headlineStyle = Theme.of(context).textTheme.headlineMedium!;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium!;
    _headlineFontSize = headlineStyle.fontSize!;
    _bodyFontSize = bodyStyle.fontSize!;
    _tertiaryColor = Theme.of(context).colorScheme.tertiary;
    _bodyTextColor = bodyStyle.color!;
    _headlineFontFamily = headlineStyle.fontFamily;
    _bodyFontFamily = bodyStyle.fontFamily;

    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPushNext() => setState(() => _acceptsInput = false);

  @override
  void didPopNext() => setState(() => _acceptsInput = true);

  @override
  void dispose() {
    _subscription?.cancel();
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    for (final n in _highlightNotifiers) {
      n.dispose();
    }
    super.dispose();
  }

  // Only flips two ValueNotifiers. No setState().
  void _setHighlightedElement(int newIndex) {
    if (newIndex == _highlightedElementIndex) return;
    final old = _highlightedElementIndex;
    _highlightedElementIndex = newIndex;
    if (old >= 0 && old < _highlightNotifiers.length) {
      _highlightNotifiers[old].value = false;
    }
    if (newIndex >= 0 && newIndex < _highlightNotifiers.length) {
      _highlightNotifiers[newIndex].value = true;
    }
  }

  void _scrollOneRow(double distance, ScrollDirection direction) {
    final end = clampDouble(
      _scrollController.offset + distance,
      0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      end,
      duration: const Duration(milliseconds: 100),
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

  Future<void> _inputProcessor(NavInput event) async {
    if (!_acceptsInput || !_scrollController.hasClients) return;

    switch (event) {
      case NavInput.up:
        if (_highlightedElementIndex <= 1) return;
        _setHighlightedElement(_highlightedElementIndex - 2);
        _activeRow--;
        if (_topRow != 1 && _activeRow == _topRow) {
          _scrollOneRow(-_rowHeight, ScrollDirection.down);
        }
        break;

      case NavInput.down:
        if (_highlightedElementIndex >= _activePlayerRewardIds.length - 2) return;
        _setHighlightedElement(_highlightedElementIndex + 2);
        _activeRow++;
        if (_scrollController.position.maxScrollExtent != _scrollController.offset &&
            _bottomRow == _activeRow) {
          _scrollOneRow(_rowHeight, ScrollDirection.up);
        }
        break;

      case NavInput.left:
        if (_highlightedElementIndex == 0) return;
        if (_highlightedElementIndex % 2 == 0) _activeRow--;
        _setHighlightedElement(_highlightedElementIndex - 1);
        if (_topRow != 1 && _activeRow == _topRow) {
          _scrollOneRow(-_rowHeight, ScrollDirection.down);
        }
        break;

      case NavInput.right:
        if (_highlightedElementIndex == _activePlayerRewardIds.length - 1) return;
        if (_highlightedElementIndex != 0 && _highlightedElementIndex % 2 != 0) {
          _activeRow++;
        }
        _setHighlightedElement(_highlightedElementIndex + 1);
        if (_scrollController.position.maxScrollExtent != _scrollController.offset &&
            _bottomRow == _activeRow) {
          _scrollOneRow(_rowHeight, ScrollDirection.up);
        }
        break;

      case NavInput.select:
        await _redeemSelectedReward();
        break;

      case NavInput.back:
        Navigator.of(context).pop();
        break;
    }
  }

  Future<void> _redeemSelectedReward() async {
    if (_activePlayerRewardIds.isEmpty) return;

    final rewardId = _activePlayerRewardIds[_highlightedElementIndex];
    final result = await RedeemReward.open(context, rewardId, widget.activePlayerId);
    if (!mounted || result != true) return;

    final rewards = _rewardsOfActivePlayer;
    if (!rewards.containsKey(rewardId)) return;

    final newAmount = rewards[rewardId]! - 1;
    if (newAmount > 0) {
      // Amount-only change: rebuild is cheap here, but we still need it
      // because RewardCell reads rewardAmount from the parent.
      setState(() => rewards[rewardId] = newAmount);
      return;
    }

    // Item fully consumed.
    final removedIndex = _activePlayerRewardIds.indexOf(rewardId);
    if (removedIndex == -1) return;

    final wasHighlighted = removedIndex == _highlightedElementIndex;

    rewards.remove(rewardId);
    _activePlayerRewardIds.removeAt(removedIndex);
    _highlightNotifiers.removeAt(removedIndex).dispose();

    if (_activePlayerRewardIds.isEmpty) {
      _highlightedElementIndex = 0;
    } else {
      if (removedIndex < _highlightedElementIndex) _highlightedElementIndex--;
      if (_highlightedElementIndex >= _activePlayerRewardIds.length) {
        _highlightedElementIndex = _activePlayerRewardIds.length - 1;
      }
      if (wasHighlighted) {
        _highlightNotifiers[_highlightedElementIndex].value = true;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final screenDiagonal = sqrt(
      screenSize.width * screenSize.width + screenSize.height * screenSize.height,
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
              fontSize: _headlineFontSize * fontScalingFactor,
              backgroundColor: _tertiaryColor,
              textColor: _bodyTextColor,
              fontFamily: _headlineFontFamily!,
            ),
          ),
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                _rowHeight = constraints.maxHeight / _rowCountToShow;
                return GridView.builder(
                  controller: _scrollController,
                  itemCount: _activePlayerRewardIds.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: _rowHeight,
                  ),
                  itemBuilder: (context, index) {
                    final rewardId = _activePlayerRewardIds[index];
                    return RewardCell(
                      key: ValueKey(rewardId),
                      rewardId: rewardId,
                      rewardAmount: _rewardsOfActivePlayer[rewardId]!,
                      screenDiagonal: screenDiagonal,
                      width: columnWidth,
                      height: constraints.maxHeight / 7,
                      highlightNotifier: _highlightNotifiers[index],
                      tertiaryColor: _tertiaryColor,
                      bodyTextColor: _bodyTextColor,
                      bodyFontFamily: _bodyFontFamily,
                      bodyFontSize: _bodyFontSize,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// One cell. Kept separate so highlight changes don't rebuild the whole grid.
/// RepaintBoundary isolates the marquee repaints to this cell.
class RewardCell extends StatelessWidget {
  final int rewardId;
  final int rewardAmount;
  final double screenDiagonal;
  final double width;
  final double height;
  final ValueListenable<bool> highlightNotifier;
  final Color tertiaryColor;
  final Color bodyTextColor;
  final String? bodyFontFamily;
  final double bodyFontSize;

  const RewardCell({
    super.key,
    required this.rewardId,
    required this.rewardAmount,
    required this.screenDiagonal,
    required this.width,
    required this.height,
    required this.highlightNotifier,
    required this.tertiaryColor,
    required this.bodyTextColor,
    required this.bodyFontFamily,
    required this.bodyFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final rewardData = RewardCatalog.getById(rewardId);
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            outlinedText(
              '${rewardAmount}x ',
              fontSize: bodyFontSize * screenDiagonal * 0.001,
              backgroundColor: tertiaryColor,
              textColor: bodyTextColor,
              fontFamily: bodyFontFamily!,
            ),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: highlightNotifier,
                builder: (context, isHighlighted, _) => RewardElement(
                  rewardText: rewardData.text,
                  screenDiagonal: screenDiagonal,
                  width: width,
                  height: height,
                  borderColor: isHighlighted ? Colors.white : rewardData.rarity.borderColor,
                  fillColor: rewardData.rarity.fillColor,
                  rotate: false,
                  scroll: isHighlighted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ScrollDirection { up, down }