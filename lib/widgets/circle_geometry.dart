import 'dart:math';
import 'package:flutter/material.dart';

class CircleGeometry {
  final Offset center;
  final double radius;

  const CircleGeometry({required this.center, required this.radius});

  Offset pointAt(double angle) {
    final a = angle - pi / 2;
    return Offset(
      center.dx + radius * cos(a),
      center.dy + radius * sin(a),
    );
  }
}

Offset topLeftFor(Offset center, Size size) {
  return Offset(center.dx - size.width / 2, center.dy - size.height / 2);
}