import 'package:couple_gacha/navigation/input_source.dart';
import 'package:flutter/material.dart';

class InputSourceProvider extends StatefulWidget {
  const InputSourceProvider({
    super.key,
    required this.inputSource,
    required this.child,
  });

  final InputSource inputSource;
  final Widget child;

  static InputSourceInherited? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InputSourceInherited>();
  }

  static InputSourceInherited of(BuildContext context) {
    final InputSourceInherited? result = maybeOf(context);
    assert(result != null, 'No InputSourceProvider found in context');
    return result!;
  }

  @override
  State<StatefulWidget> createState() => _InputSourceProviderState();
}

class _InputSourceProviderState extends State<InputSourceProvider> {
  @override
  Widget build(BuildContext context) {
    return InputSourceProvider(
      inputSource: widget.inputSource,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    widget.inputSource.dispose();
    super.dispose();
  }
}

class InputSourceInherited extends InheritedWidget {
  const InputSourceInherited({
    super.key,
    required this.inputSource,
    required super.child,
  });

  final InputSource inputSource;

  @override
  bool updateShouldNotify(InputSourceInherited oldWidget) {
    return inputSource != oldWidget.inputSource;
  }
}
