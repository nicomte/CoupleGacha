// challenges_list_title_entry.dart
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';

class ChallengesListTitleEntry extends StatelessWidget {
  const ChallengesListTitleEntry({
    super.key,
    required this.challengesListSize,
    required this.titleText,
    required this.textStyle,
  });

  final Size challengesListSize;
  final String titleText;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final padding = challengesListSize.width * 0.03;
    final borderWidth = 5.0;

    return Container(
      width: double.infinity,
      height: challengesListSize.height * 0.15,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          bottomLeft: Radius.circular(50),
        ),
        color: Theme.of(context).colorScheme.primary,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
            width: borderWidth,
          ),
          left: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
            width: borderWidth,
          ),
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
            width: borderWidth,
          ),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: outlinedText(
          titleText,
          fontSize: textStyle.fontSize!,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          textColor: textStyle.color!,
          fontFamily: textStyle.fontFamily!,
        ),
      ),
    );
  }
}