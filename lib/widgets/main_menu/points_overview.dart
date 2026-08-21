import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';

class PointsOverview extends StatefulWidget {
  final Size screenSize;

  const PointsOverview({
    super.key,
    required this.screenSize
  });

  static const List<(String, int)> _users = [
    ('Player 1', 100),
    ('Player 2', 100),
  ];

  @override
  State<PointsOverview> createState() => _PointsOverviewState();
}

class _PointsOverviewState extends State<PointsOverview> {
  @override
  Widget build(BuildContext context) {
    final pointsContainerSize = Size(
      widget.screenSize.width / 3,
      widget.screenSize.height / 3.5,
    );

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: outlinedText(
                  'Points',
                  fontSize: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontSize!,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).textTheme.headlineMedium!.color!,
                  fontFamily: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontFamily!,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...PointsOverview._users.asMap().entries.map((entry) {
                    final index = entry.key;
                    final user = entry.value.$1;
                    final points = entry.value.$2;
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
                            ).textTheme.bodyMedium!.fontSize!,
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
