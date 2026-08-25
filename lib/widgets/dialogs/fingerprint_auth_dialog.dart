import 'dart:math';

import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FingerprintAuthDialog extends StatefulWidget {
  const FingerprintAuthDialog({super.key, required this.screenDiagonal});

  final double screenDiagonal;
  @override
  State<FingerprintAuthDialog> createState() => _FingerprintAuthDialogState();
}

class _FingerprintAuthDialogState extends State<FingerprintAuthDialog> {
  String message = 'Waiting for authentication';

  @override
  Widget build(BuildContext context) {

    return Container(
      width: widget.screenDiagonal * 0.3,
      height: widget.screenDiagonal * 0.5,
      decoration: BoxDecoration(
        border: BoxBorder.all(
          color: Theme.of(context).colorScheme.tertiary,
          width: 5.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final  fontScalingFactor = sqrt(pow(width, 2) + pow(height, 2)) * 0.1;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              outlinedText(
                'Put registered finger on seonsor to authenticate.',
                fontSize:
                    Theme.of(context).textTheme.headlineMedium!.fontSize! *
                    fontScalingFactor,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                textColor: Theme.of(context).textTheme.headlineMedium!.color!,
                fontFamily: Theme.of(
                  context,
                ).textTheme.headlineMedium!.fontFamily!,
              ),
              FractionallySizedBox(
                widthFactor: 0.3,
                heightFactor: 0.3,
                child: SvgPicture.asset('assets/fingerprint.svg'),
              ),

              outlinedText(
                message,
                fontSize:
                    Theme.of(context).textTheme.bodyMedium!.fontSize! *
                    fontScalingFactor,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                textColor: Theme.of(context).textTheme.bodyMedium!.color!,
                fontFamily: Theme.of(context).textTheme.bodyMedium!.fontFamily!,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  outlinedText(
                    'Press',
                    fontSize:
                        Theme.of(context).textTheme.labelMedium!.fontSize! *
                        fontScalingFactor,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    textColor: Theme.of(context).textTheme.labelMedium!.color!,
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.labelMedium!.fontFamily!,
                  ),
                                SizedBox(width: width * 0.03),
                  SvgPicture.asset(
                    '/assets/red_button',
                    width: width * 0.05,
                    height: width * 0.05,
                  ),
                                SizedBox(width: width * 0.03),
                  outlinedText(
                    'to cancel.',
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
          );
        },
      ),
    );
  }
}
