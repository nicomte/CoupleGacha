// challenges_list_entry.dart
import 'package:couple_gacha/widgets/main_menu/challenge_list/redeem_challenge_button.dart';
import 'package:couple_gacha/widgets/main_menu/challenge_list/scrolling_area.dart';
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
  // --- highlight width expansion ---
  static const double _restingWidthFactor = 0.85;
  late final AnimationController _highlightController;
  late final Animation<double> _widthFactor;

  @override
  void initState() {
    super.initState();

    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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
    _highlightController.dispose();
    super.dispose();
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
          return Stack(
            clipBehavior: Clip.none,
            children: [
              FractionallySizedBox(
                widthFactor: _widthFactor.value,
                child: child,
              ),
              Positioned(
                right: 20,
                bottom: -12,
                  child: AnimatedOpacity(
                    opacity: widget.isHighlighted ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 100),
                    child: RedeemChallengeButton(
                      challengesListSizeHeight:
                          widget.challengesListSize.height,
                    ),
                  ),
              ),
            ],
          );
        },
        child: Container(
          width: double.infinity,
          height: widget.challengesListSize.height * 0.2,
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
            mainAxisAlignment: MainAxisAlignment.start,
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
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: ScrollingArea(
                  entryText: widget.entryText,
                  textStyle: widget.textStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
