// gacha_dialog.dart
import 'dart:math';
import 'package:flutter/material.dart';

/// Shared chrome + opening animation for every dialog in the app.
/// Each specific dialog supplies its own [child] content and its own
/// static `open()`/`show()` helper with the right return type.
class GachaDialog extends StatelessWidget {
  final Widget child;

  const GachaDialog({super.key, required this.child});

  static Future<T?> show<T>(BuildContext context, Widget child) {
    return showGeneralDialog<T>(
      context: context,
      pageBuilder: (c, a1, a2) => GachaDialog(child: child),
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: false,
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          Transform.scale(scale: animation.value, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(pow(size.width, 2) + pow(size.height, 2));

    return Dialog(
      child: Container(
        width: screenDiagonal * 0.2,
        height: screenDiagonal * 0.3,
        decoration: BoxDecoration(
          border: BoxBorder.all(
            color: Theme.of(context).colorScheme.tertiary,
            width: 5.0,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: child,
      ),
    );
  }
}