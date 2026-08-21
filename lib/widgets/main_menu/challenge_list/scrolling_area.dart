import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';

class ScrollingArea extends StatefulWidget {
  const ScrollingArea({
    super.key,
    required this.entryText,
    required this.textStyle,
  });

  final String entryText;
  final TextStyle textStyle;

  @override
  State<ScrollingArea> createState() => _StateScrollingArea();
}

class _StateScrollingArea extends State<ScrollingArea>
  with SingleTickerProviderStateMixin {

  late final AnimationController _scrollController;
  double? _lastDistance;

  void _updateScrolling(double distance) {
    if (_lastDistance == distance) return;
    _lastDistance = distance;

    if (distance <= 0) {
      _scrollController.stop();
      return;
    }

    _scrollController.duration = Duration(
      milliseconds: (distance / 50 * 1000).round(),
    );
    _scrollController.repeat();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final fontSize = constraints.maxHeight * 0.5;
          final painter = TextPainter(
            text: TextSpan(
              text: widget.entryText,
              style: TextStyle(
                fontFamily: widget.textStyle.fontFamily,
                fontSize: fontSize,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2,
              ),
            ),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout(maxWidth: double.infinity);

          final naturalWidth = painter.width;
          final distance =
              naturalWidth - constraints.maxWidth.clamp(0.0, double.infinity);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _updateScrolling(distance);
          });

          return ClipRect(
            child: SizedBox(
              width: constraints.maxWidth,
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(-_scrollController.value * distance, 0),
                    child: child,
                  );
                },
                child: OverflowBox(
                  maxWidth: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: outlinedText(
                    widget.entryText,
                    fontSize: fontSize,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    textColor: widget.textStyle.color!,
                    fontFamily: widget.textStyle.fontFamily!,
                  ),
                ),
              ),
            ),
          );
        },
      );
  }
}
