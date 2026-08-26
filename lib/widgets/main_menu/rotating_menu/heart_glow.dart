import 'package:couple_gacha/widgets/util/element_utils.dart';
import 'package:couple_gacha/widgets/main_menu/rotating_menu/circle_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math';

class HeartGlow extends StatelessWidget {
  final CircleGeometry geometry;
  final Size baseSize;
  final double scalingFactorGlow = 1.2;

  const HeartGlow({
    super.key,
    required this.geometry,
    required this.baseSize
  });

  @override
  Widget build(BuildContext context) {
    final glowSize = Size(
      baseSize.width * scalingFactorGlow,
      baseSize.height * scalingFactorGlow,
    );

    final glowCenter = geometry.pointAt(pi / 2);
    final topLeft = topLeftCentered(glowCenter, glowSize);
    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      child: Transform.rotate(
        angle: pi / 2,
        child: SvgPicture.asset(
          'assets/heart_glow.svg',
          height: glowSize.height,
          width: glowSize.width,
        ),
      ),
    );
  }
}
