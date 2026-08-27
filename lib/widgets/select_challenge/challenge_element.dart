import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChallengeElement extends StatefulWidget {
  final bool isHighlighted;
  final String category;
  final double screenDiagonal;

  const ChallengeElement({
    super.key,
    required this.isHighlighted,
    required this.category,
    required this.screenDiagonal,
  });

  @override
  State<ChallengeElement> createState() => _ChallengeElementState();
}

class _ChallengeElementState extends State<ChallengeElement>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _heartScale = Tween<double>(
    begin: 1.0,
    end: 1.125, // 0.9 / 0.8 — grows the 0.8-width heart to 0.9-width
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void initState() {
    if (widget.isHighlighted) _controller.value = 1.0;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChallengeElement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      widget.isHighlighted ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) => Stack(
        alignment: AlignmentGeometry.center,
        children: [
          ScaleTransition(
            scale: _heartScale,
            child: SvgPicture.asset(
              'assets/challenge_heart.svg',
              width: constraints.maxWidth * 0.8,
              colorFilter: widget.isHighlighted
                  ? const ColorFilter.mode(
                      Color.fromARGB(125, 255, 255, 255),
                      BlendMode.srcATop,
                    )
                  : null,
            ),
          ),
          Transform.translate(
            offset: Offset(0, -constraints.maxHeight * 0.06),
            child: outlinedText(
              widget.category,
              fontSize:
                  Theme.of(context).textTheme.bodyMedium!.fontSize! *
                  constraints.maxWidth *
                  0.003,
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              textColor: Theme.of(context).textTheme.bodyMedium!.color!,
              fontFamily: Theme.of(context).textTheme.bodyMedium!.fontFamily!,
            ),
          ),
        ],
      )),
    );
  }
}
