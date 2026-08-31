import 'package:couple_gacha/storage/players.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';

class PointsOverview extends StatefulWidget {
  final Size screenSize;
  final double screenDiagonal;

  const PointsOverview({
    super.key,
    required this.screenSize,
    required this.screenDiagonal
  });

  @override
  State<PointsOverview> createState() => _PointsOverviewState();
}

class _PointsOverviewState extends State<PointsOverview> {
  @override
  Widget build(BuildContext context) {
    final pointsContainerSize = Size(
      widget.screenSize.width / 2.2,
      widget.screenSize.height / 2.5,
    );
    double fontSizeFactor = widget.screenDiagonal * 0.001;

    return Positioned(
      left: widget.screenSize.width - pointsContainerSize.width,
      top: widget.screenSize.height - pointsContainerSize.height,
      child: Container(
        clipBehavior: Clip.antiAlias,
        width: pointsContainerSize.width,
        height: pointsContainerSize.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(50)),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
              width: 10,
            ),
            left: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
              width: 10,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: outlinedText(
                  'Points',
                  fontSize: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontSize! * fontSizeFactor,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).textTheme.headlineMedium!.color!,
                  fontFamily: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontFamily!,
                ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...players.asMap().entries.map((entry) {
                    final index = entry.key;
                    final user = entry.value.playerName;
                    final points = entry.value.points;
                    return Expanded(
                      child: Container(
                        color: index % 2 == 0
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: outlinedText(
                            '$user - $points Points',
                            fontSize: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.fontSize! * fontSizeFactor,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.tertiary,
                            textColor: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color!,
                            fontFamily: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.fontFamily!,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
