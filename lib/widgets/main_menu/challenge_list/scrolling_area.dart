import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';

class ScrollingArea extends StatefulWidget {
  const ScrollingArea({
    super.key,
    required this.entryText,
    required this.textStyle,
    this.pixelsPerSecond = 50,
    this.gap,
  });

  final String entryText;
  final TextStyle textStyle;

  /// Constant scroll speed in logical pixels/second.
  final double pixelsPerSecond;

  /// Empty space between repeats, in logical pixels. Defaults to
  /// roughly half the font size if left unset — override for an exact
  /// gap regardless of text size.
  final double? gap;

  @override
  State<ScrollingArea> createState() => _ScrollingAreaState();
}

class _ScrollingAreaState extends State<ScrollingArea>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double? _measuredForWidth;
  double? _measuredForFontSize;
  String? _measuredForText;
  double? _measuredForGap;

  double _textWidth = 0;
  double _gap = 0;
  double _tileWidth = 0; // textWidth + gap: one repeat's footprint
  int _tileCount = 0; // how many tiles are laid out to always fill the box

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _remeasureIfNeeded(double maxWidth, double fontSize) {
    final gap = widget.gap ?? fontSize * 0.6;

    if (_measuredForWidth == maxWidth &&
        _measuredForFontSize == fontSize &&
        _measuredForText == widget.entryText &&
        _measuredForGap == gap) {
      return; // nothing relevant changed
    }
    _measuredForWidth = maxWidth;
    _measuredForFontSize = fontSize;
    _measuredForText = widget.entryText;
    _measuredForGap = gap;

    // Building the text as an unused simulation to know its exact width
    final painter = TextPainter(
      text: TextSpan(
        text: widget.entryText,
        style: widget.textStyle.copyWith(fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    _textWidth = painter.width;
    _gap = gap;
    _tileWidth = _textWidth + _gap;

    // However many tiles fit across the box, plus a couple extra so the
    // box is still fully covered by real tiles at every point mid-scroll
    // (including right before a wrap, when the strip has shifted by
    // almost one full tile width).
    _tileCount = _tileWidth <= 0 ? 0 : (maxWidth / _tileWidth).ceil() + 2;

    final needsScrolling = _tileWidth > 0 && _textWidth > maxWidth;

    // Deferred because this reacts to values only known once layout has
    // happened (LayoutBuilder's constraints), and mutating the
    // AnimationController is a side effect that shouldn't run mid-build.
    // This does NOT run every frame — only when the measured inputs
    // above actually changed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!needsScrolling) {
        _controller.stop();
        return;
      }

      _controller.duration = Duration(
        milliseconds: (_tileWidth / widget.pixelsPerSecond * 1000).round(),
      );
      _controller.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final fontSize = constraints.maxHeight * 0.5;
        _remeasureIfNeeded(maxWidth, fontSize);

        if (_tileWidth <= 0) {
          return SizedBox(width: maxWidth, height: constraints.maxHeight);
        }

        if (_textWidth <= maxWidth) {
          // Fits without scrolling: show it once, statically, no
          // animation or tiling needed at all.
          return SizedBox(
            width: maxWidth,
            height: constraints.maxHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: outlinedText(
                widget.entryText,
                fontSize: fontSize,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                textColor: widget.textStyle.color!,
                fontFamily: widget.textStyle.fontFamily!,
              ),
            ),
          );
        }

        final tile = Padding(
          padding: EdgeInsets.only(right: _gap),
          child: outlinedText(
            widget.entryText,
            fontSize: fontSize,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            textColor: widget.textStyle.color!,
            fontFamily: widget.textStyle.fontFamily!,
          ),
        );

        return ClipRect(
          child: SizedBox(
            width: maxWidth,
            height: constraints.maxHeight,
            child: _TickerStrip(
              controller: _controller,
              tileWidth: _tileWidth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_tileCount, (_) => tile),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TickerStrip extends AnimatedWidget {
  const _TickerStrip({
    required Animation<double> controller,
    required this.tileWidth,
    required this.child,
  }) : super(listenable: controller);

  final double tileWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = listenable as Animation<double>;

    // Travels exactly one tile's width per cycle, then wraps — since
    // tile N+1 is identical to tile N, the wrap is invisible.
    final offset = -controller.value * tileWidth;

    return Transform.translate(
      offset: Offset(offset, 0),
      child: OverflowBox(
        maxWidth: double.infinity,
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }
}
