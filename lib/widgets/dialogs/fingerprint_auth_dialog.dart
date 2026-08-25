import 'dart:async';
import 'dart:math';
import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FingerprintAuthDialog extends StatefulWidget {
  const FingerprintAuthDialog({
    super.key,
    required this.screenDiagonal,
    required this.onSubscribed,
  });

  final double screenDiagonal;
  final VoidCallback onSubscribed;

  @override
  State<FingerprintAuthDialog> createState() => _FingerprintAuthDialogState();
}

class _FingerprintAuthDialogState extends State<FingerprintAuthDialog> {
  String message = 'Waiting for authentication';
  StreamSubscription<NavInput>? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);

  }

  @override
  void initState() {
    super.initState();
    widget.onSubscribed();
  }

  void _inputProcessor(NavInput input) {
    if (input == NavInput.back) {}
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: widget.screenDiagonal * 0.2,
        height: widget.screenDiagonal * 0.3,
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
            final fontScalingFactor =
                sqrt(pow(width, 2) + pow(height, 2)) * 0.001;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                outlinedText(
                  'Put registered finger on sensor to authenticate.',
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium!.fontSize! *
                      fontScalingFactor,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).textTheme.headlineMedium!.color!,
                  fontFamily: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontFamily!,
                ),

                SvgPicture.asset('assets/fingerprint.svg', width: width * 0.3),

                outlinedText(
                  message,
                  fontSize:
                      Theme.of(context).textTheme.bodyMedium!.fontSize! *
                      fontScalingFactor,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).textTheme.bodyMedium!.color!,
                  fontFamily: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.fontFamily!,
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
                      textColor: Theme.of(
                        context,
                      ).textTheme.labelMedium!.color!,
                      fontFamily: Theme.of(
                        context,
                      ).textTheme.labelMedium!.fontFamily!,
                    ),
                    SizedBox(width: width * 0.03),
                    SvgPicture.asset(
                      'assets/red_button.svg',
                      width: width * 0.05,
                    ),
                    SizedBox(width: width * 0.03),
                    outlinedText(
                      'to cancel.',
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize! *
                          fontScalingFactor,
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      textColor: Theme.of(
                        context,
                      ).textTheme.labelMedium!.color!,
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
      ),
    );
  }
}
