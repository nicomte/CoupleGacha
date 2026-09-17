import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/storage/rewards.dart';
import 'package:couple_gacha/widgets/redeem_challenge/redeem_challenge_element.dart';
import 'package:couple_gacha/widgets/util/select_and_return_info.dart';
import 'package:flutter/material.dart';

enum _Phase { revealing, listing, done }

class GachaReveal extends StatefulWidget {
  final int activePlayerId;
  final List<int> rewardId;

  const GachaReveal({
    super.key,
    required this.activePlayerId,
    required this.rewardId,
  });

  @override
  State<GachaReveal> createState() => _GachaRevealState();
}

class _GachaRevealState extends State<GachaReveal>
    with RouteAware, TickerProviderStateMixin {
  StreamSubscription<NavInput>? _subscription;

  _Phase _phase = _Phase.revealing;
  int _dynamicRewardIndex = 0;

  // --- Reveal (spin + scale) ---
  late final AnimationController _revealController;
  late final Animation<double> _scale;
  late final Animation<double> _angle;

  // --- Final list-in slide ---
  late final AnimationController _listController;
  late final List<Animation<double>> _slideCurves;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Scale finishes well before the spin: only the first 40% of the
    // controller's timeline is spent animating scale 0 -> 1.
    _scale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Spin runs the full timeline.
    _angle = Tween<double>(begin: 0, end: 5 * 2 * pi + pi/2).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOut),
    );

    _revealController.forward(); // reveal element 0 immediately on load

    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // One CurvedAnimation per element, staggered so they cascade in rather
    // than all sliding at once. Built once — pullAmount is fixed for the
    // widget's lifetime, so there's no need to rebuild this list later.
    _slideCurves = List.generate(widget.rewardId.length, (i) {
      final start = (i / widget.rewardId.length) * 0.5;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _listController,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _listController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _phase = _Phase.done);
      }
    });
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
  void dispose() {
    _subscription?.cancel();
    routeObserver.unsubscribe(this);
    _revealController.dispose();
    _listController.dispose();
    super.dispose();
  }

  double _targetLeftFor(int index, double height) =>
      height / 2 + (index * height * 1.8);

  void _inputProcessor(NavInput input) {
    if (input != NavInput.select) return;

    switch (_phase) {
      case _Phase.revealing:
        if (!_revealController.isCompleted) return; // spin still running

        if (widget.rewardId.length == 1) Navigator.of(context).pop();

        if (_dynamicRewardIndex + 1 < widget.rewardId.length) {
          setState(() => _dynamicRewardIndex++);
          _revealController
            ..reset()
            ..forward();
        } else {
          setState(() => _phase = _Phase.listing);
          _listController.forward();
        }
        break;

      case _Phase.listing:
        break; // ignore presses until the slide finishes on its own

      case _Phase.done:
        Navigator.of(context).pop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(
      pow(screenSize.width, 2) + pow(screenSize.height, 2),
    );
    final height = screenSize.width / 18;
    final width = screenSize.height * 0.9;

    final Widget footer = SelectAndReturnInfo.singleOption(
      buttonAsset: 'assets/green_button.svg',
      actionText: _phase == _Phase.revealing ? 'to continue.' : 'to return.',
    );

    final Widget body;
    switch (_phase) {
      case _Phase.revealing:
        body = Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _revealController,
                    builder: (context, child) => Transform.scale(
                      scale: _scale.value,
                      child: Transform.rotate(
                        angle: _angle.value,
                        child: child,
                      ),
                    ),
                    child: RedeemChallengeElement(
                      rewardText: RewardCatalog.all
                          .firstWhere(
                            (reward) =>
                                reward.id ==
                                widget.rewardId[_dynamicRewardIndex],
                          )
                          .text,
                      screenDiagonal: screenDiagonal,
                      width: width,
                      height: height,
                    ),
                  ),
                ),
              ),
            ),
            footer,
          ],
        );
        break;

      case _Phase.listing:
      case _Phase.done:
        body = Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // topOffset centers `width` (the element's *visual* height,
                  // note the swapped naming) within whatever space is actually
                  // left after the footer — not the full screen.
                  final topOffset = (constraints.maxHeight - width) / 2 + 24.0;

                  return Stack(
                    children: [
                      for (int i = 0; i < widget.rewardId.length; i++)
                        AnimatedBuilder(
                          animation: _slideCurves[i],
                          builder: (context, child) {
                            final top = Tween<double>(
                              begin: -width * 2,
                              end: topOffset,
                            ).transform(_slideCurves[i].value);

                            return Positioned(
                              top: top,
                              left: _targetLeftFor(i, height),
                              child: child!,
                            );
                          },
                          child: RedeemChallengeElement(
                            rewardText: RewardCatalog.all
                                .firstWhere(
                                  (reward) => reward.id == widget.rewardId[i],
                                )
                                .text,
                            screenDiagonal: screenDiagonal,
                            width: width,
                            height: height,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            footer,
          ],
        );
        break;
    }

    return Scaffold(body: SafeArea(child: body));
  }
}
