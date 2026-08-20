import 'package:flutter/material.dart';

Widget outlinedText(String text, {double? fontSize, required Color backgroundColor, Color? textColor, String? fontFamily}) {
  return Stack(
    children: [
      Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = backgroundColor
        ),
      ),
      Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontFamily: fontFamily
        ),
      ),
    ],
  );
}