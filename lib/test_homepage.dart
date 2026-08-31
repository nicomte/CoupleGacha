import 'package:couple_gacha/widgets/util/warning_popup.dart';
import 'package:flutter/material.dart';

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warning Popup Test'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            WarningPopup.show(
              context,
              'This is a warning message!',
              const Duration(seconds: 3),
            );
          },
          child: const Text('Show Warning'),
        ),
      ),
    );
  }
}