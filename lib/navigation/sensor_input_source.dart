import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/navigation/input_source.dart';
import 'package:dart_periphery/dart_periphery.dart';

class SensorInputSource implements InputSource {
  final int addr = 0x63;
  final int firmwareRegister = 0xFE;
  final int offset12bitRegister = 0x50;
  final int deadzone = 2000;
  bool timerActive = false;

  late final StreamController<NavInput> _controller;
  late final I2C i2c;
  NavInput? lastValidInput;

  SensorInputSource() {
    try {
      print('Creating I2C connection');
      i2c = I2C(1);
      var firmwareVersion = i2c.readByteReg(addr, firmwareRegister);
      print('Firmware version: $firmwareVersion');
    } on I2Cexception catch (e) {
      print('Error Code: ${e.errorCode} - Error Message: ${e.errorMsg}');
    }

    _controller = StreamController<NavInput>.broadcast(
      onListen: () {
        timerActive = true;
        Timer.periodic(Duration(milliseconds: 50), (timer) {
          Point joystickLocation = _pollJoystick();

          print('x: ${joystickLocation.x} - y: ${joystickLocation.y}');

          if (!_joystickOutsideDeadzone(joystickLocation)) {
            lastValidInput = null;
            return;
          }

          if (joystickLocation.x.abs() > joystickLocation.y.abs()) {
            final NavInput currentInput = joystickLocation.x >= 0
                ? NavInput.right
                : NavInput.left;
            if (lastValidInput == null) {
              _controller.add(currentInput);
              lastValidInput = currentInput;
              print(currentInput);
              return;
            }
            if (lastValidInput != currentInput) {
              _controller.add(currentInput);
              lastValidInput = currentInput;
              print(currentInput);
            }
          } else if (joystickLocation.x.abs() < joystickLocation.y.abs()) {
            final NavInput currentInput = joystickLocation.y >= 0
                ? NavInput.up
                : NavInput.down;
            if (lastValidInput == null) {
              _controller.add(currentInput);
              lastValidInput = currentInput;
              print(currentInput);
              return;
            }
            if (lastValidInput != currentInput) {
              _controller.add(currentInput);
              lastValidInput = currentInput;
              print(currentInput);
            }
          } else {
            return;
          }

          if (!timerActive) {
            timer.cancel();
          }
        });
      },

      onCancel: () {
        if (!_controller.hasListener) {
          timerActive = false;
          i2c.dispose();
        }
      },
    );
  }

  Point _pollJoystick() {
    final data = i2c.readBytesReg(addr, offset12bitRegister, 4);

    final x = (data[0] | (data[1] << 8)).toSigned(16);
    final y = -(data[2] | (data[3] << 8)).toSigned(
      16,
    ); // negated: up = positive

    return Point(x, y);
  }

  bool _joystickOutsideDeadzone(Point joystickLocation) {
    return joystickLocation.x.abs() > deadzone ||
        joystickLocation.y.abs() > deadzone;
  }

  @override
  Stream<NavInput> get events => _controller.stream;

  @override
  Future<void> dispose() async {
    await _controller.close();
    timerActive = false;
    i2c.dispose();
  }
}
