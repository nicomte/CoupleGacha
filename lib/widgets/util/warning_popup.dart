import 'dart:math';

import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';

class WarningPopup extends StatefulWidget {
  final String displayText;
  final Duration duration;

  const WarningPopup({
    super.key,
    required this.displayText,
    required this.duration,
  });

  static void show(
    BuildContext context,
    String displayText,
    Duration duration,
  ) {
    final overlayEntry = OverlayEntry(
      builder: (BuildContext context) =>
          WarningPopup(displayText: displayText, duration: duration),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  State<StatefulWidget> createState() => _WarningPopupState();
}

class _WarningPopupState extends State<WarningPopup> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontScalingFactor =
        sqrt(pow(screenSize.height, 2) + pow(screenSize.width, 2)) * 0.001;
    return Align(
      alignment: AlignmentGeometry.topCenter,
      child: Container(
        width: screenSize.width * 0.4,
        height: screenSize.height * 0.1,
        color: Theme.of(context).colorScheme.error,
        child: outlinedText(
          widget.displayText,
          fontSize: Theme.of(context).textTheme.labelMedium!.fontSize! * fontScalingFactor,
          backgroundColor: Theme.of(context).textTheme.labelMedium!.color!,
          textColor: Theme.of(context).colorScheme.tertiary,
          fontFamily: Theme.of(context).textTheme.labelMedium!.fontFamily!,
        ),
      ),
    );
  }
}
