import 'package:flutter/material.dart';

Offset topLeftCentered(Offset center, Size size) {
  return Offset(center.dx - size.width / 2, center.dy - size.height / 2);
}

Size sizeFromHeight(double height, double elementAspectRatio) =>
    Size(height * elementAspectRatio, height);