import 'package:couple_gacha/widgets/main_menu/points_overview.dart';
import 'package:couple_gacha/widgets/main_menu/rotating_menu.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(
      pow(screenSize.width, 2) + pow(screenSize.height, 2),
    );
    return Scaffold(
      body: Stack(
        children: [
          RotatingMenu(screenSize: screenSize, screenDiagonal: screenDiagonal),
          PointsOverview(
            screenSize: screenSize,
            screenDiagonal: screenDiagonal,
          ),
        ],
      ),
    );
  }
}
