import 'dart:async';
import 'dart:math';

import 'package:couple_gacha/fingerprint_scanner_isolate/sensor_service.dart';
import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/widgets/dialogs/gacha_dialog.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:couple_gacha/widgets/util/select_and_return_info.dart';
import 'package:couple_gacha/widgets/util/warning_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:m5_fpc1020a/m5_fpc1020a.dart';

class FingerprintEnrollmentDialog extends StatefulWidget {
  final String dialogText;

  const FingerprintEnrollmentDialog({
    super.key,
    this.dialogText = 'I forgot to set a dialog text',
  });

  /// Returns the new user id, or null if enrollment failed or was cancelled.
  static Future<int?> open(
    BuildContext context, {
    String dialogText = 'I forgot to set a dialog text',
  }) {
    return GachaDialog.show<int>(
      context,
      FingerprintEnrollmentDialog(dialogText: dialogText),
    );
  }

  @override
  State<FingerprintEnrollmentDialog> createState() =>
      _FingerprintEnrollmentDialogState();
}

class _FingerprintEnrollmentDialogState
    extends State<FingerprintEnrollmentDialog> {
  static const int _maxAttemptsPerScan = 3;
  static const int _scanTimeoutMs = 5000;
  static const Duration _messageDelay = Duration(milliseconds: 800);
  static const Duration _warningDuration = Duration(seconds: 3);

  late final SensorService _sensor;
  StreamSubscription<NavInput>? _subscription;

  /// Set once the dialog is cancelled or closed, so the enrollment loop stops.
  bool _closed = false;

  String _statusMessage = 'Starting sensor...';

  @override
  void initState() {
    super.initState();
    _sensor = SensorService();
    _start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);
  }

  @override
  void dispose() {
    _closed = true;
    _subscription?.cancel();
    _sensor.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Enrollment logic
  // ---------------------------------------------------------------------------

 Future<void> _start() async {
  final sensorReady = await _sensor.init();
  if (_closed || !mounted) return;

  if (!sensorReady) {
    _fail('Fingerprint sensor not found');
    return;
  }

  await _enroll();
}

  Future<void> _enroll() async {
  final userId = (await _sensor.getUserCount()) + 1;
  const scans = ScanNr.values;

  for (var i = 0; i < scans.length; i++) {
    final status = await _enrollScan(userId, scans[i], i + 1, scans.length);
    if (_closed) return; // cancelled, no warning needed

    if (status != ackSuccess) {
      _fail(_errorMessage(status));
      return;
    }
  }

  _close(userId);
}

  /// Tries one scan up to [_maxAttemptsPerScan] times.
/// Returns [ackSuccess], or the last error code from the sensor.
Future<int> _enrollScan(
  int userId,
  ScanNr scan,
  int scanNumber,
  int totalScans,
) async {
  var status = ackFail;

  for (var attempt = 1; attempt <= _maxAttemptsPerScan; attempt++) {
    // Delay so one touch is not counted as multiple attempts
    await Future.delayed(const Duration(seconds: 1));
    
    if (_closed) return ackFail;

    _setStatus('Put finger on sensor to enroll ($scanNumber/$totalScans)');

    status = await _sensor.addFingerprint(
      userId,
      _scanTimeoutMs,
      PermissionLevel.master,
      scan,
    );
    if (_closed) return ackFail;

    if (status == ackSuccess) {
      _setStatus('Success ($scanNumber/$totalScans)');
      await Future.delayed(_messageDelay);
      return ackSuccess;
    }

    // Retrying can't fix a full sensor or an existing user.
    if (status == ackFull || status == ackUserExist) return status;

    _setStatus(
      'Scan $scanNumber failed (attempt $attempt/$_maxAttemptsPerScan)',
    );
    await Future.delayed(_messageDelay);
  }
  return status;
}

String _errorMessage(int status) {
  switch (status) {
    case ackTimeout:
      return 'No finger detected. Enrollment timed out';
    case ackFull:
      return 'Sensor memory is full';
    case ackUserExist:
      return 'This fingerprint is already enrolled';
    default:
      return 'Enrollment failed';
  }
}

/// Shows a warning on top of everything and closes the dialog immediately.
void _fail(String message) {
  if (_closed || !mounted) return;
  WarningPopup.show(context, message, _warningDuration);
  _close(null);
}

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setStatus(String message) {
    if (!mounted || _closed) return;
    setState(() => _statusMessage = message);
  }

  void _close(int? result) {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).pop(result);
  }

  Future<void> _inputProcessor(NavInput input) async {
    if (input != NavInput.back || _closed) return;

    _setStatus('Cancelling...');
    await Future.delayed(_messageDelay);
    _close(null);
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineMedium!;
    final bodyStyle = theme.textTheme.bodyMedium!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final fontScale = sqrt(width * width + height * height) * 0.001;

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            outlinedText(
              widget.dialogText,
              fontSize: titleStyle.fontSize! * fontScale,
              backgroundColor: theme.colorScheme.tertiary,
              textColor: titleStyle.color!,
              fontFamily: titleStyle.fontFamily!,
            ),
            SvgPicture.asset('assets/fingerprint.svg', width: width * 0.3),
            outlinedText(
              _statusMessage,
              fontSize: bodyStyle.fontSize! * fontScale,
              backgroundColor: theme.colorScheme.tertiary,
              textColor: bodyStyle.color!,
              fontFamily: bodyStyle.fontFamily!,
            ),
            SelectAndReturnInfo.singleOption(
              buttonAsset: 'assets/red_button.svg',
              actionText: 'to cancel.',
            ),
          ],
        );
      },
    );
  }
}