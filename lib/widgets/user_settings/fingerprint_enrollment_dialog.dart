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
  /// How many complete enrollments (ADD_1 ... ADD_3) are tried before giving
  /// up. The sensor aborts the whole enrollment when a step fails, and
  /// re-sending only the failed step is rejected instantly, so a retry always
  /// has to start from the first scan.
  static const int _maxEnrollRounds = 3;

  /// Host-side wait per scan command. With a finger on the sensor it answers
  /// in ~1.5 s, so this only matters when no finger is present.
  static const int _scanTimeoutMs = 8000;

  static const Duration _messageDelay = Duration(milliseconds: 800);
  static const Duration _restartDelay = Duration(milliseconds: 2000);
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
    final count = await _sensor.getUserCount();
    if (_closed) return;
    if (count < 0) {
      _fail('Could not read fingerprint sensor');
      return;
    }
    final userId = count + 1;

    var status = ackFail;
    for (var round = 1; round <= _maxEnrollRounds; round++) {
      status = await _enrollRound(userId);
      if (_closed) return;

      if (status == ackSuccess) {
        _close(userId);
        return;
      }

      // Timeout / sensor full / already enrolled: starting over can't fix it.
      if (status != ackFail) break;

      // Generic failure: the sensor dropped this enrollment. Remove anything
      // half-written and start again from the first scan.
      await _sensor.delFingerprint(userId);
      if (_closed) return;

      if (round < _maxEnrollRounds) {
        _setStatus('Scan failed. Starting over ($round/$_maxEnrollRounds)');
        await Future.delayed(_restartDelay);
        if (_closed) return;
      }
    }

    _fail(_errorMessage(status));
  }

  /// One complete enrollment pass: ADD_1, ADD_2 x4, ADD_3 (all six scans).
  /// Returns [ackSuccess], or the code of the scan that failed.
  Future<int> _enrollRound(int userId) async {
    const scans = ScanNr.values;

    for (var i = 0; i < scans.length; i++) {
      final status = await _enrollScan(userId, scans[i], i + 1, scans.length);
      if (_closed || status != ackSuccess) return status;
    }
    return ackSuccess;
  }

  /// A single attempt for one scan. No same-command retry here: once a step
  /// fails the sensor rejects the same command again within milliseconds.
  Future<int> _enrollScan(
    int userId,
    ScanNr scan,
    int scanNumber,
    int totalScans,
  ) async {
    _setStatus(
      'Ready to scan ($scanNumber/$totalScans)',
    );

    final status = await _sensor.addFingerprint(
      userId,
      _scanTimeoutMs,
      PermissionLevel.master,
      scan,
    );
    if (_closed) return ackFail;

    if (status == ackSuccess) {
      _setStatus('Success ($scanNumber/$totalScans)');
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
        return 'Enrollment failed. Press your finger firmly and keep it still';
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
        final fontScale = sqrt(width * width + height * height) * 0.0005;

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
              fontSize: bodyStyle.fontSize! * fontScale * 2,
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