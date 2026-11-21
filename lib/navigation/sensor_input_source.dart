import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/widgets/util/warning_popup.dart';
import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/material.dart';

class SensorInputSource implements InputSource {
  final int _addr = 0x63;
  final int _firmwareRegister = 0xFE;
  final int _offset12bitRegister = 0x50;
  final int _deadzone = 2000;
  final int _greenButtonGpio = 16;
  final int _redButtonGpio = 5;

  final StreamController<NavInput> _controller =
      StreamController<NavInput>.broadcast();

  I2C? _i2c;
  GPIO? _greenButton;
  GPIO? _redButton;
  Timer? _timer;
  NavInput? _lastJoystickInput;
  bool _greenButtonLastState = false;
  bool _redButtonLastState = false;

  SensorInputSource(this._navigatorKey) {
    _start();
  }

  final GlobalKey<NavigatorState> _navigatorKey;

  void _start() {
    try {
      final config = GPIOconfig.defaultValues();
      config.direction = GPIOdirection.gpioDirIn;
      config.bias = GPIObias.gpioBiasPullUp;
      _greenButton = GPIO.advanced(_greenButtonGpio, config);
      _redButton = GPIO.advanced(_redButtonGpio, config);

      _i2c = I2C(1);
      final firmwareVersion = _i2c!.readByteReg(_addr, _firmwareRegister);
      print('Firmware version: $firmwareVersion');

      _timer = Timer.periodic(const Duration(milliseconds: 50), _watchSensors);
    } on I2Cexception catch (e) {
      final ctx = _navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        WarningPopup.show(
          ctx,
          'Failed to connect joystick. Check hardware or restart.',
          const Duration(seconds: 3),
        );
      }
      print('Error Code: ${e.errorCode} - Error Message: ${e.errorMsg}');
    }
  }

  void _watchSensors(Timer _) {
    try {
      _watchButtons();
      _watchJoystick();
    } catch (e) {
      // Don't let a single bad read kill the polling timer
      print('Sensor read failed: $e');
    }
  }

  void _watchButtons() {
    final greenButtonPressed = !_greenButton!.read();
    final redButtonPressed = !_redButton!.read();

    if (greenButtonPressed && !_greenButtonLastState) {
      _controller.add(NavInput.select);
    }
    if (redButtonPressed && !_redButtonLastState) {
      _controller.add(NavInput.back);
    }
    _greenButtonLastState = greenButtonPressed;
    _redButtonLastState = redButtonPressed;
  }

  void _watchJoystick() {
    final location = _pollJoystick();

    if (!_joystickOutsideDeadzone(location)) {
      _lastJoystickInput = null;
      return;
    }

    final currentInput = _getCurrentJoystickInput(location);

    if (currentInput != null && currentInput != _lastJoystickInput) {
      _controller.add(currentInput);
    }
    _lastJoystickInput = currentInput;
  }

  Point<int> _pollJoystick() {
    final data = _i2c!.readBytesReg(_addr, _offset12bitRegister, 4);
    final x = (data[0] | (data[1] << 8)).toSigned(16);
    final y = -(data[2] | (data[3] << 8)).toSigned(16);
    return Point(x, y);
  }

  bool _joystickOutsideDeadzone(Point<int> p) =>
      p.x.abs() > _deadzone || p.y.abs() > _deadzone;

  NavInput? _getCurrentJoystickInput(Point<int> p) {
    if (p.x.abs() > p.y.abs()) {
      return p.x >= 0 ? NavInput.right : NavInput.left;
    } else if (p.x.abs() < p.y.abs()) {
      return p.y >= 0 ? NavInput.down : NavInput.up;
    }
    return null;
  }

  @override
  Stream<NavInput> get events => _controller.stream;

  @override
  Future<void> dispose() async {
    _timer?.cancel();
    _i2c?.dispose();
    _greenButton?.dispose();
    await _controller.close();
  }
}
