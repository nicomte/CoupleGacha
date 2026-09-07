import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/storage/rewards.dart';
import 'package:couple_gacha/widgets/redeem_challenge/redeem_challenge_element.dart';
import 'package:flutter/material.dart';

class GachaReveal extends StatefulWidget {
  final int activePlayerId;
  final int pullAmount;

  const GachaReveal({
    super.key,
    required this.activePlayerId,
    required this.pullAmount,
  });

  @override
  State<GachaReveal> createState() => _GachaRevealState();
}

class _GachaRevealState extends State<GachaReveal> with RouteAware, SingleTickerProviderStateMixin{
  StreamSubscription<NavInput>? _subscription;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  double? _startLeft;
  double? _targetLeft;
  bool _isDone = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isDone = true);
      }
    });
    super.initState();
  }


  @override
  void didChangeDependencies() {
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);

    routeObserver.subscribe(this, ModalRoute.of(context)!);

    // Compute layout-dependent offsets once, now that MediaQuery is available.
    if (_startLeft == null) {
      final screenSize = MediaQuery.of(context).size;
      final height = screenSize.width / 18;

      _startLeft = (screenSize.width / 2) - (height / 2);
      _targetLeft = height / 2; // single-element case for now

      _animation = Tween<double>(
        begin: _startLeft!,
        end: _targetLeft!,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_subscription != null) _subscription!.cancel();
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  void _inputProcessor(NavInput input) {
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
        if (_isDone) {
          Navigator.of(context).pop();
        } else {startAnimation();}

      case NavInput.back:
        // Nothing to do
        break;
    }
  }

  void startAnimation(){
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(
      pow(screenSize.width, 2) + pow(screenSize.height, 2),
    );
    final height = screenSize.width / 18;
    final width = screenSize.height * 0.9;
    final topOffset = (screenSize.height - width) / 2;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(animation: _animation, builder: (context, child){
            return Positioned(top: topOffset, left: _animation.value,
              child: RedeemChallengeElement(
                rewardText: rewards[0].text,
                screenDiagonal: screenDiagonal,
                width: width,
                height: height,
              ));           
            
          })
        ],
      ),
    );
  }
}
