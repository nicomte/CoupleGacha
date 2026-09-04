import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/storage/players.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:couple_gacha/widgets/util/select_and_return_info.dart';
import 'package:couple_gacha/widgets/util/warning_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RedeemPoints extends StatefulWidget {
  final int activePlayerId;

  const RedeemPoints({super.key, required this.activePlayerId});

  @override
  State<RedeemPoints> createState() => _RedeemPointsState();
}

class _RedeemPointsState extends State<RedeemPoints> with RouteAware, SingleTickerProviderStateMixin {
  bool _acceptsInput = true;
  StreamSubscription<NavInput>? _subscription;
  int _activeOptionIndex = 0;

  late int _playerPointAmount;
  int _pointCost = 1;

  late final AnimationController _controller;
  // Grows the currently-active heart from 1.0 -> 1.125
  late final Animation<double> _growAnimation;
  // Shrinks the previously-active heart from 1.125 -> 1.0, in lockstep
  late final Animation<double> _shrinkAnimation;

  @override
  void initState() {
    _playerPointAmount = players.firstWhere((p) => p.playerId == widget.activePlayerId).points;
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _growAnimation = Tween<double>(begin: 1, end: 1.125).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _shrinkAnimation = Tween<double>(begin: 1.125, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.value = 1.0;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);

    routeObserver.subscribe(this, ModalRoute.of(context)!);

    super.didChangeDependencies();
  }

  @override
  void didPushNext() => setState(() => _acceptsInput = false);

  @override
  void didPopNext() => setState(() => _acceptsInput = true);

  @override
  void dispose() {
    if (_subscription != null) _subscription!.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _inputProcessor(NavInput input) {
    if (!_acceptsInput) return;
    switch (input) {
      case NavInput.up:
        // Nothing to do
        break;
      case NavInput.down:
        // Nothing to do
        break;
      case NavInput.left:
        setState(() {
          _activeOptionIndex = _activeOptionIndex == 0 ? 1 : 0;
          _pointCost = _pointCost == 1 ? 9 : 1;
        });
        _controller.forward(from: 0);
        break;
      case NavInput.right:
        setState(() {
          _activeOptionIndex = _activeOptionIndex == 0 ? 1 : 0;
          _pointCost = _pointCost == 1 ? 9 : 1;
        });
        _controller.forward(from: 0);
        break;
      case NavInput.select:
        if (_playerPointAmount <= _pointCost){
          WarningPopup.show(context, 'Not enough points', Duration(seconds: 3));
        }
      case NavInput.back:
        Navigator.of(context).pop();
    }
  }

  Widget _buildHeart(int index, double screenDiagonal) {
    final bool isHighlighted = index == _activeOptionIndex;
    return ScaleTransition(
      scale: isHighlighted ? _growAnimation : _shrinkAnimation,
      child: SvgPicture.asset(
        'assets/challenge_heart.svg',
        width: screenDiagonal * 0.2,
        colorFilter: isHighlighted
            ? const ColorFilter.mode(
                Color.fromARGB(125, 255, 255, 255),
                BlendMode.srcATop,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenDiagonal = sqrt(
      pow(MediaQuery.of(context).size.height, 2) +
          pow(MediaQuery.of(context).size.width, 2),
    );
    double fontScalingFactor = screenDiagonal * 0.001;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          outlinedText(
            'You have $_playerPointAmount points',
            fontSize:
                Theme.of(context).textTheme.headlineMedium!.fontSize! *
                fontScalingFactor,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            textColor: Theme.of(context).textTheme.headlineMedium!.color!,
            fontFamily: Theme.of(context).textTheme.headlineMedium!.fontFamily!,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  _buildHeart(0, screenDiagonal),
                  SizedBox(height: screenDiagonal * 0.01),
                  outlinedText(
                    '1 Pull = 1 Point',
                    fontSize:
                        Theme.of(context).textTheme.labelMedium!.fontSize! *
                        fontScalingFactor,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    textColor: Theme.of(context).textTheme.labelMedium!.color!,
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.labelMedium!.fontFamily!,
                  ),
                ],
              ),
              Column(
                children: [
                  _buildHeart(1, screenDiagonal),
                  SizedBox(height: screenDiagonal * 0.01),
                  outlinedText(
                    '10 Pulls = 9 Points',
                    fontSize:
                        Theme.of(context).textTheme.labelMedium!.fontSize! *
                        fontScalingFactor,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    textColor: Theme.of(context).textTheme.labelMedium!.color!,
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.labelMedium!.fontFamily!,
                  ),
                ],
              ),
            ],
          ),
          SelectAndReturnInfo.selectOrReturn(),
        ],
      ),
    );
  }
}