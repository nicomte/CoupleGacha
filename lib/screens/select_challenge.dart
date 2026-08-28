import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
//import 'package:couple_gacha/storage/active_challenges.dart';
import 'package:couple_gacha/storage/challenges.dart';
import 'package:couple_gacha/widgets/dialogs/reveal_challenge.dart';
import 'package:couple_gacha/widgets/select_challenge/challenge_element.dart';
import 'package:couple_gacha/widgets/util/select_and_return_info.dart';
import 'package:flutter/material.dart';

class SelectChallenge extends StatefulWidget {
  const SelectChallenge({super.key, required this.activePlayerId});

  final int activePlayerId;
  final int numberOfChoices = 3;

  @override
  State<SelectChallenge> createState() => _SelectChallengeState();
}

class _SelectChallengeState extends State<SelectChallenge> with RouteAware {
  StreamSubscription<NavInput>? _subscription;
  bool _acceptsInput = true;
  int _activeChallengeIndex = 0;

  @override
  void didChangeDependencies() {
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);
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
    super.dispose();
  }

  void _inputProcessor(NavInput input) {
    if (!_acceptsInput) return;

    switch (input) {
      case NavInput.back:
      Navigator.of(context).pop();
      case NavInput.up:
      // Nothing to do
      break;
      case NavInput.down:
      // Nothing to do
      break;
      case NavInput.left:
        _decreaseIndex();
        break;
      case NavInput.right:
        _increaseIndex();
        break;
      case NavInput.select:
        RevealChallenge.open(context, challenges[_activeChallengeIndex]);
        /*
        activeChallenges[widget.activePlayerId] = challenges[_activeChallengeIndex].challengeText;
        Navigator.of(context).pop();
        */
    }
  }

  void _increaseIndex() {
    setState(() {
      _activeChallengeIndex =
          (_activeChallengeIndex + 1) % widget.numberOfChoices;
    });
  }

  void _decreaseIndex() {
    setState(() {
      _activeChallengeIndex =
          (_activeChallengeIndex - 1) % widget.numberOfChoices;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenDiagonal = sqrt(
      pow(MediaQuery.of(context).size.height, 2) +
          pow(MediaQuery.of(context).size.width, 2),
    );
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                ...challenges.asMap().entries.map(
                  (entry) => Expanded(
                    child: ChallengeElement(
                      isHighlighted: entry.key == _activeChallengeIndex
                          ? true
                          : false,
                      category: entry.value.challengeCategory,
                      screenDiagonal: screenDiagonal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: SelectAndReturnInfo.selectOrReturn()),
        ],
      ),
    );
  }
}
