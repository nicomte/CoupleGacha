import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SelectAndReturnInfo extends StatelessWidget {
  const SelectAndReturnInfo({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: ((context, constraints) {
      final double fontScalingFactor = constraints.maxWidth * 0.0015;
      final double spacerWidth = constraints.maxWidth * 0.01;
      final double buttonWidth = constraints.maxWidth * 0.02;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          outlinedText(
            'Press',
            fontSize:
                Theme.of(context).textTheme.labelMedium!.fontSize! *
                fontScalingFactor,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            textColor: Theme.of(context).textTheme.labelMedium!.color!,
            fontFamily: Theme.of(context).textTheme.labelMedium!.fontFamily!,
          ),
          SizedBox(width: spacerWidth),
          SvgPicture.asset('assets/green_button.svg', width: buttonWidth),
          SizedBox(width: spacerWidth),
          outlinedText(
            'to select or',
            fontSize:
                Theme.of(context).textTheme.labelMedium!.fontSize! *
                fontScalingFactor,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            textColor: Theme.of(context).textTheme.labelMedium!.color!,
            fontFamily: Theme.of(context).textTheme.labelMedium!.fontFamily!,
          ),
                    SizedBox(width: spacerWidth),
          SvgPicture.asset('assets/red_button.svg', width: buttonWidth),
          SizedBox(width: spacerWidth),
          outlinedText(
            'to return.',
            fontSize:
                Theme.of(context).textTheme.labelMedium!.fontSize! *
                fontScalingFactor,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            textColor: Theme.of(context).textTheme.labelMedium!.color!,
            fontFamily: Theme.of(context).textTheme.labelMedium!.fontFamily!,
          ),
        ],
      );
    }),
  );
}
