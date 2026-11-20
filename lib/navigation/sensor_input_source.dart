import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:dart_periphery/dart_periphery.dart';

class SensorInputSource implements InputSource {
  final int _addr = 0x63;
  final int _firmwareRegister = 0xFE;
  final int _offset12bitRegister = 0x50;
  final int _deadzone = 2000;

  late final StreamController<NavInput> _controller;
  late final I2C _i2c;
  late final Timer _timer;
  NavInput? _lastInput;

  SensorInputSource() {
    _controller = StreamController<NavInput>.broadcast(
      onListen: () {
        try {
          print('Creating I2C connection');
          _i2c = I2C(1);
          var firmwareVersion = _i2c.readByteReg(_addr, _firmwareRegister);
          print('Firmware version: $firmwareVersion');
        } on I2Cexception catch (e) {
          print('Error Code: ${e.errorCode} - Error Message: ${e.errorMsg}');
        }
        _timer = Timer.periodic(Duration(milliseconds: 50), _watchJoystick);
      },

      onCancel: () {
        if (!_controller.hasListener) {
          _timer.cancel();
          _i2c.dispose();
        }
      },
    );
  }

  void _watchJoystick(_) {
    Point<int> joystickLocation = _pollJoystick();

    if (!_joystickOutsideDeadzone(joystickLocation)) {
      _lastInput = null;
      return;
    }

    final currentInput = _getCurrentInput(joystickLocation);

    if (_lastInput != currentInput && currentInput != null) {
      _controller.add(currentInput);
    }

    if (_lastInput != currentInput) {
      _lastInput = currentInput;
    }
  }

  Point<int> _pollJoystick() {
    final data = _i2c.readBytesReg(_addr, _offset12bitRegister, 4);

    final x = (data[0] | (data[1] << 8)).toSigned(16);
    final y = -(data[2] | (data[3] << 8)).toSigned(
      16,
    ); // negated: up = positive

    return Point(x, y);
  }

  bool _joystickOutsideDeadzone(Point joystickLocation) {
    return joystickLocation.x.abs() > _deadzone ||
        joystickLocation.y.abs() > _deadzone;
  }

  NavInput? _getCurrentInput(Point<int> joystickLocation) {
    if (joystickLocation.x.abs() > joystickLocation.y.abs()) {
      return joystickLocation.x >= 0 ? NavInput.right : NavInput.left;
    } else if (joystickLocation.x.abs() < joystickLocation.y.abs()) {
      return joystickLocation.y >= 0 ? NavInput.up : NavInput.down;
    } else {
      return null;
    }
  }

  @override
  Stream<NavInput> get events => _controller.stream;

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
