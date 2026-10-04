import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';

class UserElement extends StatelessWidget {
  final String userName;
  final double screenDiagonal;
  final double screenWidth;

  const UserElement({
    super.key,
    required this.userName,
    required this.screenDiagonal,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          width: 5,
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      child: outlinedText(
        userName,
        fontSize: screenDiagonal * 0.05,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        textColor: Theme.of(context).textTheme.bodyMedium!.color!,
        fontFamily: Theme.of(context).textTheme.bodyMedium!.fontFamily!,
      ),
    );
  }
}
