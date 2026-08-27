import 'dart:async';
import 'dart:math';
import 'package:couple_gacha/fingerprint_scanner_isolate/sensor_service.dart';
import 'package:couple_gacha/navigation/input_source.dart';
import 'package:couple_gacha/navigation/input_source_provider.dart';
import 'package:couple_gacha/widgets/dialogs/auth_enums.dart';
import 'package:couple_gacha/widgets/util/outlined_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:m5_fpc1020a/m5_fpc1020a.dart';

class FingerprintAuthDialog extends StatefulWidget {
  const FingerprintAuthDialog({super.key});

  @override
  State<FingerprintAuthDialog> createState() => _FingerprintAuthDialogState();
}

class _FingerprintAuthDialogState extends State<FingerprintAuthDialog> {
  StreamSubscription<NavInput>? _subscription;
  String _statusMessage = AuthStatus.authenticating.message();
  late final SensorService _fingerprintSensor;
  bool _fingerprintSensorActive = false;

  bool _streamReady = false;
  bool _authStarted = false;

  @override
  void initState() {
    super.initState();
    _fingerprintSensor = SensorService();
    _initFingerprintSensor();
    _maybeStartAuth();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= InputSourceProvider.of(
      context,
    ).inputSource.events.listen(_inputProcessor);
    _streamReady = true;
    _maybeStartAuth();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _fingerprintSensor.dispose();
    super.dispose();
  }

  Future<void> _initFingerprintSensor() async {
    _fingerprintSensorActive = await _fingerprintSensor.init();

    if (!mounted) return;

    setState(() {});

    _maybeStartAuth();
  }

  void _closedWith(AuthResult result) {
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  void _maybeStartAuth() {
    if (_fingerprintSensorActive && _streamReady && !_authStarted) {
      _authStarted = true;
      _authenticateFinger();
    }
  }

  Future<void> _authenticateFinger() async {
    final int maxRetries = 3;
    int retryCounter = 0;
    MatchResult result;

    while (maxRetries > retryCounter) {
      if (!mounted) return;

      if (!_fingerprintSensorActive) {
        throw StateError('Please connect to sensor.');
      }

      result = await _fingerprintSensor.matchFingerprint(8000);

      if (!mounted) return;

      if (result.success == true) {
        setState(() {
          _statusMessage = AuthStatus.success.message();
        });
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        _closedWith(AuthSuccess(result.userId!));
        return;

      } else {
        retryCounter++;
        setState(() {
          _statusMessage = AuthStatus.failure.message(retryCounter, maxRetries);
        });
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _closedWith(AuthFailed());
    return;
  }

  Future<void> _inputProcessor(NavInput input) async {
    if (input == NavInput.back) {
      setState(() {
        _statusMessage = AuthStatus.canceled.message();
      });

      await Future.delayed(const Duration(milliseconds: 300));

      _closedWith(AuthCancelled());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(pow(size.width, 2) + pow(size.height, 2));
    return Dialog(
      child: Container(
        width: screenDiagonal * 0.2,
        height: screenDiagonal * 0.3,
        decoration: BoxDecoration(
          border: BoxBorder.all(
            color: Theme.of(context).colorScheme.tertiary,
            width: 5.0,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),

        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final fontScalingFactor =
                sqrt(pow(width, 2) + pow(height, 2)) * 0.001;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                outlinedText(
                  'Put registered finger on sensor to authenticate.',
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium!.fontSize! *
                      fontScalingFactor,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).textTheme.headlineMedium!.color!,
                  fontFamily: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontFamily!,
                ),

                SvgPicture.asset('assets/fingerprint.svg', width: width * 0.3),

                outlinedText(
                  _statusMessage,
                  fontSize:
                      Theme.of(context).textTheme.bodyMedium!.fontSize! *
                      fontScalingFactor,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).textTheme.bodyMedium!.color!,
                  fontFamily: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.fontFamily!,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    outlinedText(
                      'Press',
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize! *
                          fontScalingFactor,
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      textColor: Theme.of(
                        context,
                      ).textTheme.labelMedium!.color!,
                      fontFamily: Theme.of(
                        context,
                      ).textTheme.labelMedium!.fontFamily!,
                    ),
                    SizedBox(width: width * 0.03),
                    SvgPicture.asset(
                      'assets/red_button.svg',
                      width: width * 0.05,
                    ),
                    SizedBox(width: width * 0.03),
                    outlinedText(
                      'to cancel.',
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize! *
                          fontScalingFactor,
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      textColor: Theme.of(
                        context,
                      ).textTheme.labelMedium!.color!,
                      fontFamily: Theme.of(
                        context,
                      ).textTheme.labelMedium!.fontFamily!,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
