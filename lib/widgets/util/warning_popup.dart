import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';

class WarningPopup extends StatefulWidget {
  final String displayText;
  final Duration duration;
  final VoidCallback onDismissed;

  const WarningPopup({
    super.key,
    required this.displayText,
    required this.duration,
    required this.onDismissed,
  });

  static Future<void> show(
    BuildContext context,
    String displayText,
    Duration duration,
  ) async {
    late OverlayEntry overlayEntry;
    final completer = Completer<void>();

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => WarningPopup(
        displayText: displayText,
        duration: duration,
        onDismissed: () {
          overlayEntry.remove();
          completer.complete();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    await completer.future;
  }

  @override
  State<StatefulWidget> createState() => _WarningPopupState();
}

class _WarningPopupState extends State<WarningPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetY;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..forward();

    _offsetY = Tween<double>(
      begin: -1,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _runSequence();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  Future<void> _runSequence() async {
    await _controller.forward();
    await Future.delayed(widget.duration);
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontScalingFactor =
        sqrt(pow(screenSize.height, 2) + pow(screenSize.width, 2)) * 0.0008;

    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: AlignmentGeometry.topCenter,

        child: AnimatedBuilder(
          animation: _offsetY,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _offsetY.value * (screenSize.height * 0.05)),

            child: Container(
              alignment: Alignment.center,
              width: screenSize.width * 0.4,
              height: screenSize.height * 0.1,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),

              child: outlinedText(
                widget.displayText,
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
      ),
    );
  }
}
