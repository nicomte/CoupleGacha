import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A single piece of the prompt row - either a text label or a button icon.
sealed class PromptSegment {
  const PromptSegment();
}

class TextSegment extends PromptSegment {
  final String text;
  const TextSegment(this.text);
}

class ButtonSegment extends PromptSegment {
  final String assetPath;
  const ButtonSegment(this.assetPath);
}

class SelectAndReturnInfo extends StatelessWidget {
  final List<PromptSegment> segments;

  const SelectAndReturnInfo({super.key, required this.segments});

  /// "Press <green> to select or <red> to return."
  factory SelectAndReturnInfo.selectOrReturn({
    Key? key,
    String selectButtonAsset = 'assets/green_button.svg',
    String returnButtonAsset = 'assets/red_button.svg',
  }) =>
      SelectAndReturnInfo(
        key: key,
        segments: [
          const TextSegment('Press'),
          ButtonSegment(selectButtonAsset),
          const TextSegment('to select or'),
          ButtonSegment(returnButtonAsset),
          const TextSegment('to return.'),
        ],
      );

  /// "Press <button> to close." (single available option)
  factory SelectAndReturnInfo.singleOption({
    Key? key,
    required String buttonAsset,
    required String actionText,
  }) =>
      SelectAndReturnInfo(
        key: key,
        segments: [
          const TextSegment('Press'),
          ButtonSegment(buttonAsset),
          TextSegment(actionText),
        ],
      );

  /// "Press <button> to close. Or Press <button> to cancel."
  factory SelectAndReturnInfo.twoOptions({
    Key? key,
    required String firstButtonAsset,
    required String firstActionText,
    required String secondButtonAsset,
    required String secondActionText,
  }) =>
      SelectAndReturnInfo(
        key: key,
        segments: [
          const TextSegment('Press'),
          ButtonSegment(firstButtonAsset),
          TextSegment(firstActionText),
          const TextSegment('Or Press'),
          ButtonSegment(secondButtonAsset),
          TextSegment(secondActionText),
        ],
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final double fontScalingFactor = constraints.maxWidth * 0.0015;
          final double spacerWidth = constraints.maxWidth * 0.01;
          final double buttonWidth = constraints.maxWidth * 0.02;

          final textTheme = Theme.of(context).textTheme.labelMedium!;
          final backgroundColor = Theme.of(context).colorScheme.tertiary;

          final children = <Widget>[];
          for (var i = 0; i < segments.length; i++) {
            final segment = segments[i];
            switch (segment) {
              case TextSegment(:final text):
                children.add(
                  outlinedText(
                    text,
                    fontSize: textTheme.fontSize! * fontScalingFactor,
                    backgroundColor: backgroundColor,
                    textColor: textTheme.color!,
                    fontFamily: textTheme.fontFamily!,
                  ),
                );
              case ButtonSegment(:final assetPath):
                children.add(SvgPicture.asset(assetPath, width: buttonWidth));
            }
            if (i != segments.length - 1) {
              children.add(SizedBox(width: spacerWidth));
            }
          }

          return Row(mainAxisSize: MainAxisSize.min, children: children);
        },
      );
}