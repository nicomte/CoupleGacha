import 'dart:async';
import 'dart:isolate';

import 'package:m5_fpc1020a/m5_fpc1020a.dart';

import 'sensor_isolate_protocol.dart';
import 'sensor_isolate_worker.dart';

/// UI-isolate-facing handle to the fingerprint sensor.
///
/// This is the only class your widgets should ever import. It spawns and
/// owns one long-lived worker isolate, which in turn owns the
/// `M5Fpc1020a` driver and its open serial port for as long as the
/// service is alive.
///
/// Every method here returns a `Future` and is safe to `await` directly
/// in widget code / `setState` — none of it blocks the UI thread, no
/// matter how long the sensor takes to respond.


class SensorService {
  Isolate? _isolate;
  SendPort? _workerPort;
  StreamSubscription? _subscription;

  final _pending = <int, Completer<dynamic>>{};
  int _nextRequestId = 0;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Spawns the worker isolate and opens the serial port. Call this once
  /// — typically in `initState()` — before using any other method.
  /// Returns whatever `M5Fpc1020a.begin()` returns (true/false).
  Future<bool> init({int baud = 19200, String port = '/dev/serial0'}) async {
    if (_initialized) return true;

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(sensorIsolateEntry, receivePort.sendPort);
    final broadcast = receivePort.asBroadcastStream();
    // First message from the worker is always its SendPort.
    _workerPort = await broadcast.first as SendPort;


    _subscription = broadcast.listen((message) {
      final response = message as SensorResponse;
      final completer = _pending.remove(response.requestId);
      if (completer == null) return;
      if (response.error != null) {
        completer.completeError(response.error!);
      } else {
        completer.complete(response.result);
      }
    });

    final result = await _send<bool>(
      BeginCmd(_id(), baud: baud, port: port)
    );

    _initialized = result;

    return result;
  }

  Future<bool> setBaud(int baud) => _send(SetBaudCmd(_id(), baud));

  Future<List<MapEntry<int, int>>?> getAllUsers() =>
      _send(GetAllUsersCmd(_id()));

  Future<bool> enterSleepMode() => _send(EnterSleepModeCmd(_id()));

  Future<int> setFingerMode(FingerRepeatMode mode) =>
      _send(SetFingerModeCmd(_id(), mode));

  Future<int> getFingerMode() => _send(GetFingerModeCmd(_id()));

  Future<int> getUserCount() => _send(GetUserCountCmd(_id()));

  Future<int> delAllFingerprints() => _send(DelAllFingerprintsCmd(_id()));

  Future<int> delFingerprint(int userId) =>
      _send(DelFingerprintCmd(_id(), userId));

  Future<int> addFingerprint(
    int userId,
    int timeout,
    PermissionLevel permission,
    ScanNr scanNr,
  ) =>
      _send(AddFingerprintCmd(_id(), userId, timeout, permission, scanNr));

  /// Waits up to [timeout] ms for a finger on the sensor. This is the
  /// call `_authenticateFinger` uses — safe to `await` directly, the UI
  /// keeps rendering the whole time.
  Future<MatchResult> matchFingerprint(int timeout) =>
      _send(MatchFingerprintCmd(_id(), timeout));

  int _id() => _nextRequestId++;

  Future<T> _send<T>(SensorCommand command) {
    final completer = Completer<T>();
    _pending[command.requestId] = completer;
    _workerPort!.send(command);
    return completer.future;
  }

  /// Closes the serial port and kills the worker isolate. Call this from
  /// `dispose()` of whatever owns the `SensorService` — do not skip this,
  /// an un-killed isolate leaks and keeps the serial port open.
  /// After calling this, [init] must be called again before further use.
  Future<void> dispose() async {
    if (!_initialized) return;
    _workerPort?.send(ShutdownCmd(_id()));
    await _subscription?.cancel();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _workerPort = null;
    _initialized = false;
    for (final c in _pending.values) {
      if (!c.isCompleted) {
        c.completeError(StateError('SensorService disposed'));
      }
    }
    _pending.clear();
  }
}