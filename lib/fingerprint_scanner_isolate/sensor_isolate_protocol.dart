import 'package:m5_fpc1020a/m5_fpc1020a.dart';

/// Base class for every request sent TO the worker isolate.
/// Each command carries a [requestId] so the matching response can be
/// routed back to the right caller.
sealed class SensorCommand {
  final int requestId;
  const SensorCommand(this.requestId);
}

class BeginCmd extends SensorCommand {
  final int baud;
  final String port;
  const BeginCmd(super.requestId,
      {this.baud = 19200, this.port = '/dev/serial0'});
}

class SetBaudCmd extends SensorCommand {
  final int baud;
  const SetBaudCmd(super.requestId, this.baud);
}

class GetAllUsersCmd extends SensorCommand {
  const GetAllUsersCmd(super.requestId);
}

class EnterSleepModeCmd extends SensorCommand {
  const EnterSleepModeCmd(super.requestId);
}

class SetFingerModeCmd extends SensorCommand {
  final FingerRepeatMode mode;
  const SetFingerModeCmd(super.requestId, this.mode);
}

class GetFingerModeCmd extends SensorCommand {
  const GetFingerModeCmd(super.requestId);
}

class GetUserCountCmd extends SensorCommand {
  const GetUserCountCmd(super.requestId);
}

class DelAllFingerprintsCmd extends SensorCommand {
  const DelAllFingerprintsCmd(super.requestId);
}

class DelFingerprintCmd extends SensorCommand {
  final int userId;
  const DelFingerprintCmd(super.requestId, this.userId);
}

class AddFingerprintCmd extends SensorCommand {
  final int userId;
  final int timeout;
  final PermissionLevel permission;
  final ScanNr scanNr;
  const AddFingerprintCmd(
    super.requestId,
    this.userId,
    this.timeout,
    this.permission,
    this.scanNr,
  );
}

class MatchFingerprintCmd extends SensorCommand {
  final int timeout;
  const MatchFingerprintCmd(super.requestId, this.timeout);
}

/// Tells the worker isolate to close the port and stop. No response is
/// expected for this one — the isolate is killed right after.
class ShutdownCmd extends SensorCommand {
  const ShutdownCmd(super.requestId);
}

/// Sent back FROM the worker isolate once a command finishes.
/// Exactly one of [result] / [error] will be set.
class SensorResponse {
  final int requestId;
  final dynamic result;
  final Object? error;
  const SensorResponse(this.requestId, {this.result, this.error});
}