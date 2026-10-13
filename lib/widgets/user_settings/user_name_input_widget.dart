import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/route_observer.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';

import 'package:flutter/material.dart';

/// Full-screen arcade style name input.
///
/// Pops with a [String]:
///  - the entered name when the confirm key is pressed
///  - an empty string when the user leaves with `NavInput.back`
/// ```
class UserNameInputWidget extends StatefulWidget {
  const UserNameInputWidget({super.key});

  @override
  State<UserNameInputWidget> createState() => _UserNameInputWidgetState();
}

class _UserNameInputWidgetState extends State<UserNameInputWidget>
    with RouteAware {
  // ---------------------------------------------------------------- config
  static const int _maxNameLength = 12;
  static const int _columns = 10;

  // Font scaling factors (multiplied with the screen diagonal)
  static const double _nameFontFactor = 0.07;
  static const double _keyFontFactor = 0.035;

  static const String _backspaceKey = 'DEL';
  static const String _confirmKey = 'OK';

  // A-Z, then backspace, then confirm
  static final List<String> _keys = [
    for (int c = 'A'.codeUnitAt(0); c <= 'Z'.codeUnitAt(0); c++)
      String.fromCharCode(c),
    _backspaceKey,
    _confirmKey,
  ];

  // ----------------------------------------------------------------- state
  StreamSubscription<NavInput>? _subscription;
  bool _acceptsInput = true;

  String _name = '';
  int _highlightedIndex = 0;

  int get _rows => (_keys.length / _columns).ceil();

  // ------------------------------------------------------------- lifecycle
  @override
  void didChangeDependencies() {
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void didPushNext() => setState(() => _acceptsInput = false);

  @override
  void didPopNext() => setState(() => _acceptsInput = true);

  @override
  void dispose() {
    _subscription?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // ----------------------------------------------------------- navigation
  Future<void> _inputProcessor(NavInput input) async {
    if (!_acceptsInput || !mounted) return;

    switch (input) {
      case NavInput.back:
        Navigator.of(context).pop('');
        break;
      case NavInput.left:
        _moveHorizontal(-1);
        break;
      case NavInput.right:
        _moveHorizontal(1);
        break;
      case NavInput.up:
        _moveVertical(-1);
        break;
      case NavInput.down:
        _moveVertical(1);
        break;
      case NavInput.select:
        _activateHighlighted();
        break;
    }
  }

  /// Left/right by one. Stops at the first/last key (no wrapping).
  void _moveHorizontal(int delta) {
    final next = _highlightedIndex + delta;
    if (next < 0 || next >= _keys.length) return;
    setState(() => _highlightedIndex = next);
  }

  /// Up/down jumps one row. Stops at the top/bottom row.
  /// If the row below is shorter (last row), jump to its last key.
  void _moveVertical(int deltaRows) {
    final currentRow = _highlightedIndex ~/ _columns;
    final targetRow = currentRow + deltaRows;
    if (targetRow < 0 || targetRow >= _rows) return;

    int next = _highlightedIndex + deltaRows * _columns;
    if (next >= _keys.length) next = _keys.length - 1;
    setState(() => _highlightedIndex = next);
  }

  // -------------------------------------------------------- business logic
  void _activateHighlighted() {
    final key = _keys[_highlightedIndex];

    switch (key) {
      case _backspaceKey:
        if (_name.isEmpty) return;
        setState(() => _name = _name.substring(0, _name.length - 1));
        break;
      case _confirmKey:
        if (_name.isEmpty) return; // nothing to confirm yet
        Navigator.of(context).pop(_name);
        break;
      default:
        if (_name.length >= _maxNameLength) return;
        setState(() => _name += key);
    }
  }

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(pow(size.height, 2) + pow(size.width, 2));
    final theme = Theme.of(context);

    final textColor = theme.textTheme.bodyMedium!.color!;
    final fontFamily = theme.textTheme.bodyMedium!.fontFamily!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ------------------------------------------------ name display
            Expanded(
              flex: 1,
              child: Center(
                child: outlinedText(
                  // trailing underscore acts as a simple cursor
                  _name.length < _maxNameLength ? '$_name _' : _name,
                  fontSize: screenDiagonal * _nameFontFactor,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  textColor: textColor,
                  fontFamily: fontFamily,
                ),
              ),
            ),

            // --------------------------------------------- character block
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.all(screenDiagonal * 0.01),
                padding: EdgeInsets.all(screenDiagonal * 0.012),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(screenDiagonal * 0.015),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final spacing = screenDiagonal * 0.008;
                    final cellWidth =
                        (constraints.maxWidth - spacing * (_columns - 1)) /
                        _columns;
                    final cellHeight =
                        (constraints.maxHeight - spacing * (_rows - 1)) /
                        _rows;

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _keys.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _columns,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: cellWidth / cellHeight,
                      ),
                      itemBuilder: (context, index) {
                        final key = _keys[index];
                        final isHighlighted = index == _highlightedIndex;

                        // Special keys get their own fill color
                        Color fill = theme.colorScheme.secondary;
                        if (key == _confirmKey) {
                          fill = theme.colorScheme.primaryContainer;
                        } else if (key == _backspaceKey) {
                          fill = theme.colorScheme.primary;
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: fill,
                            borderRadius: BorderRadius.circular(
                              screenDiagonal * 0.008,
                            ),
                            border: Border.all(
                              color: isHighlighted
                                  ? Colors.white
                                  : theme.colorScheme.primary,
                              width: isHighlighted
                                  ? screenDiagonal * 0.006
                                  : screenDiagonal * 0.002,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: outlinedText(
                              key,
                              fontSize: screenDiagonal * _keyFontFactor,
                              backgroundColor: Theme.of(context).colorScheme.tertiary,
                              textColor: textColor,
                              fontFamily: fontFamily,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}