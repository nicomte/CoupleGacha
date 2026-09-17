import 'package:couple_gacha/widgets/main_menu/challenge_list/scrolling_area.dart';
import 'package:flutter/material.dart';

class RedeemChallengeElement extends StatefulWidget {
  final String rewardText;
  final double screenDiagonal;
  final double width;
  final double height;
  final Color borderColor;
  final Color fillColor;

  const RedeemChallengeElement({
    super.key,
    required this.rewardText,
    required this.screenDiagonal,
    required this.width,
    required this.height,
    required this.borderColor,
    required this.fillColor
  });

  @override
  State<RedeemChallengeElement> createState() => _RedeemChallengeElementState();
}

class _RedeemChallengeElementState extends State<RedeemChallengeElement> {
  @override
  Widget build(BuildContext context) {
    final fontScalingFactor = widget.screenDiagonal * 0.001;

    return Align(
      child: RotatedBox(
        quarterTurns: 3,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.fillColor,
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(
              color: widget.borderColor,
              width: 5.0,
            ),
            boxShadow: [
    BoxShadow(
      color: widget.borderColor.withValues(alpha: 0.5),
      blurRadius: 12,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: widget.borderColor.withValues(alpha: 0.2),
      blurRadius: 24,
      spreadRadius: 4,
    ),
  ],
          ),
          child: ScrollingArea(
            entryText: widget.rewardText,
            textStyle: TextStyle(
              fontSize:
                  Theme.of(context).textTheme.labelMedium!.fontSize! *
                  fontScalingFactor,
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              color: Theme.of(context).textTheme.labelMedium!.color!,
              fontFamily: Theme.of(context).textTheme.labelMedium!.fontFamily!,
            ),
          ),
        ),
      ),
    );
  }
}
