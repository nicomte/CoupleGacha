import 'dart:async';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:flutter/services.dart';

class KeyboardInputSource implements InputSource {
  late final StreamController<NavInput> _controller;

  KeyboardInputSource() {
    _controller = StreamController<NavInput>.broadcast(
      onListen: () {
        HardwareKeyboard.instance.addHandler(_handleKey);
      },
      onCancel: () {
        if (!_controller.hasListener) {
          HardwareKeyboard.instance.removeHandler(_handleKey);
        }
      },
    );
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        _controller.add(NavInput.up);
        break;
      case LogicalKeyboardKey.arrowDown:
        _controller.add(NavInput.down);
        break;
      case LogicalKeyboardKey.arrowLeft:
        _controller.add(NavInput.left);
        break;
      case LogicalKeyboardKey.arrowRight:
        _controller.add(NavInput.right);
        break;
      case LogicalKeyboardKey.enter:
        _controller.add(NavInput.select);
        break;
      case LogicalKeyboardKey.escape:
        _controller.add(NavInput.back);
        break;
    }
    return false;
  }

  @override
  Stream<NavInput> get events => _controller.stream;

  @override
  Future<void> dispose() async {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    await _controller.close();
  }
}
