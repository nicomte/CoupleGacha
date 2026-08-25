import 'package:flutter/material.dart';

Widget outlinedText(String text, {required double fontSize, required Color backgroundColor, required Color textColor, required String fontFamily}) {
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
        textAlign: TextAlign.center,
      ),
      Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontFamily: fontFamily
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}