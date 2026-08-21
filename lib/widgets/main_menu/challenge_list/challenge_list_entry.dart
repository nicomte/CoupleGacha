// challenges_list_entry.dart
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';

class ChallengesListEntry extends StatefulWidget {
  const ChallengesListEntry({
    super.key,
    required this.challengesListSize,
    required this.entryText,
    required this.playerName,
    required this.textStyle,
    this.isHighlighted = false,
  });

  final Size challengesListSize;
  final String entryText;
  final String playerName;
  final TextStyle textStyle;
  final bool isHighlighted;

  @override
  State<ChallengesListEntry> createState() => _StateChallengesListEntry();
}

class _StateChallengesListEntry extends State<ChallengesListEntry>
    with TickerProviderStateMixin {
  // --- marquee scroll ---
  late final AnimationController _scrollController;
  double? _lastDistance;

  // --- highlight width expansion ---
  static const double _restingWidthFactor = 0.85;
  late final AnimationController _highlightController;
  late final Animation<double> _widthFactor;

  @override
  void initState() {
    super.initState();

    _scrollController = AnimationController(vsync: this);

    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.isHighlighted ? 1 : 0,
    );
    _widthFactor = Tween<double>(begin: _restingWidthFactor, end: 1.0).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant ChallengesListEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
        _highlightController.forward();
      } else {
        _highlightController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final padding = widget.challengesListSize.width * 0.03;
    final borderWidth = 5.0;

    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedBuilder(
        animation: _widthFactor,
        builder: (context, child) {
          return FractionallySizedBox(
            widthFactor: _widthFactor.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: widget.challengesListSize.height * 0.15,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              bottomLeft: Radius.circular(50),
            ),
            color: Theme.of(context).colorScheme.primary,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
                width: borderWidth,
              ),
              left: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
                width: borderWidth,
              ),
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
                width: borderWidth,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return outlinedText(
                      widget.playerName,
                      fontSize: constraints.maxWidth * 0.2,
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      textColor: widget.textStyle.color!,
                      fontFamily: widget.textStyle.fontFamily!,
                    );
                  },
                ),
              ),
              Expanded(
                flex: 5,
                child: LayoutBuilder(
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
                        naturalWidth -
                        constraints.maxWidth.clamp(0.0, double.infinity);

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
                              offset: Offset(
                                -_scrollController.value * distance,
                                0,
                              ),
                              child: child,
                            );
                          },
                          child: OverflowBox(
                            maxWidth: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: outlinedText(
                              widget.entryText,
                              fontSize: fontSize,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.tertiary,
                              textColor: widget.textStyle.color!,
                              fontFamily: widget.textStyle.fontFamily!,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
