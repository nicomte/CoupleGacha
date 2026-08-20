import 'package:flutter/material.dart';

class PointsOverview extends StatelessWidget {
  const PointsOverview({
    super.key,
    required this.screenSize,
    required this.screenDiagonal,
  });

  final Size screenSize;
  final double screenDiagonal;

  @override
  Widget build(BuildContext context) {
    final pointsContainerWidth = screenSize.width / 3;
    final pointsContainerHeight = screenSize.height / 4;
    return Positioned(
          left: screenSize.width - pointsContainerWidth,
          top: screenSize.height - pointsContainerHeight,
          child: Container(
            width: pointsContainerWidth,
            height: pointsContainerHeight,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
  }
}
