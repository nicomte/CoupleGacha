import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/storage/active_challenges.dart';
//import 'package:couple_gacha/storage/active_challenges.dart';
import 'package:couple_gacha/storage/challenges.dart';
import 'package:couple_gacha/widgets/dialogs/replace_active_challenge.dart';
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
    routeObserver.subscribe(this, ModalRoute.of(context)!);
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
      _decreaseIndex();
      break;
    case NavInput.right:
      _increaseIndex();
      break;
    case NavInput.select:
      await _handleSelect();
      break;
  }
}

Future<void> _handleSelect() async {
  if (activeChallenges.containsKey(widget.activePlayerId)) {
    final result = await ReplaceActiveChallenge.open(
      context,
      widget.activePlayerId,
    );
    if (result != true) return;
    if (!mounted) return;
  }

  await _revealChallengeAndClose();
}

Future<void> _revealChallengeAndClose() async {
  await RevealChallenge.open(
    context,
    challenges[_activeChallengeIndex],
    widget.activePlayerId,
  );
  if (!mounted) return;

  _acceptsInput = false;
  await Future.delayed(const Duration(milliseconds: 300));
  if (!mounted) return;
  Navigator.of(context).pop();
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
