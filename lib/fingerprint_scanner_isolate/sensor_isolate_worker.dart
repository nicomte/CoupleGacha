import 'dart:isolate';
import 'package:m5_fpc1020a/m5_fpc1020a.dart';
import 'sensor_isolate_protocol.dart';

/// Entry point that runs INSIDE the worker isolate.
///
/// This is where all of `M5Fpc1020a`'s blocking busy-wait loops actually
/// execute. Because it's a separate isolate with its own memory and its
/// own event loop, none of that blocking touches the UI isolate — the
/// app stays responsive no matter how long `_sendCmd`'s while-loop spins.
///
/// Passed to `Isolate.spawn`. Runs once, sets up a `ReceivePort` to listen
/// for commands, and keeps a single `M5Fpc1020a` instance alive for the
/// life of the isolate.
void sensorIsolateEntry(SendPort mainSendPort) {
  final commandPort = ReceivePort();
  // Hand our SendPort back to the UI isolate so it can talk to us.
  mainSendPort.send(commandPort.sendPort);

  final driver = M5Fpc1020a();

  commandPort.listen((message) {
    final command = message as SensorCommand;

    if (command is ShutdownCmd) {
      driver.dispose();
      commandPort.close();
      return;
    }

    try {
      // Every branch here runs synchronously and may block THIS isolate
      // for a while (up to the relevant timeout) — that's fine, it's not
      // the UI isolate.
      final dynamic result = switch (command) {
        BeginCmd(:final baud, :final port) => driver.begin(
          baud: baud,
          port: port,
        ),
        SetBaudCmd(:final baud) => driver.setBaud(baud),
        GetAllUsersCmd() => driver.getAllUsers(),
        EnterSleepModeCmd() => driver.enterSleepMode(),
        SetFingerModeCmd(:final mode) => driver.setFingerMode(mode),
        GetFingerModeCmd() => driver.getFingerMode(),
        GetUserCountCmd() => driver.getUserCount(),
        DelAllFingerprintsCmd() => driver.delAllFingerprints(),
        DelFingerprintCmd(:final userId) => driver.delFingerprint(userId),
        AddFingerprintCmd(
          :final userId,
          :final timeout,
          :final permission,
          :final scanNr,
        ) =>
          driver.addFingerprint(userId, timeout, permission, scanNr),
        MatchFingerprintCmd(:final timeout) =>
          driver.matchFingerprintUserPermission(timeout),
        ShutdownCmd() => null, // handled above; unreachable here
      };
      mainSendPort.send(SensorResponse(command.requestId, result: result));
    } catch (e, st) {
      mainSendPort.send(SensorResponse(command.requestId, error: '$e\n$st'));
    }
  });
}
