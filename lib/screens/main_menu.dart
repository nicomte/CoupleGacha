import 'package:couple_gacha/widgets/main_menu/rotating_menu.dart';
import 'package:couple_gacha/methods/element_utils.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_svg/svg.dart';

class MainMenu extends StatefulWidget{
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    final screenDiagonal = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2));
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RotatingMenu(screenSize: screenSize, screenDiagonal: screenDiagonal),
          ),
          Expanded(
            child: Builder(builder: (_) {
              final height = screenDiagonal / 15;
              return SvgPicture.asset('assets/heart_arrow.svg', height: height, width: sizeFromHeight(height / 5.5, 3.57721578342).width);
            })
          )
        ],
      )
    );
  }
}