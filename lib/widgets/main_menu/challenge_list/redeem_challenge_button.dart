import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';

class RedeemChallengeButton extends StatefulWidget {
  const RedeemChallengeButton({
    super.key,
    required this.challengesListSizeHeight,
  });

  final double challengesListSizeHeight;

  @override
  State<StatefulWidget> createState() => _StateRedeemChallengeButton();
}

class _StateRedeemChallengeButton extends State<RedeemChallengeButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(50),
          border: BoxBorder.all(
            color: Theme.of(context).colorScheme.tertiary,
            width: 3,
          ),
        ),
        child: outlinedText(
          'Redeem?',
          fontSize: widget.challengesListSizeHeight * 0.05,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          textColor: Theme.of(context).textTheme.labelMedium!.color!,
          fontFamily: Theme.of(context).textTheme.labelMedium!.fontFamily!,
        ),
      );
  }
}
