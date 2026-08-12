import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math';

class RotatingMenu extends StatefulWidget{
  const RotatingMenu({super.key});

  static const List<String> menuAssetPaths = [
    'assets/check_rewards_heart.svg',
    'assets/player_settings_heart.svg',
    'assets/redeem_points_heart.svg',
    'assets/select_challenge_heart.svg',
  ];

  @override
  State<RotatingMenu> createState() => _RotatingMenuState();
}

class _RotatingMenuState extends State<RotatingMenu> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        for (int i = 0; i < RotatingMenu.menuAssetPaths.length; i++)
          _buildMenuItem(i)
      ],
    ),
  );

  Widget _buildMenuItem(int index) {
    //final isSelected = index == selectedIndex;
    final circleCenterX = MediaQuery.of(context).size.width / 4;
    final circleCenterY = MediaQuery.of(context).size.height / 2;
    final angle = pi / 180 * 90 * index;
    final width = MediaQuery.of(context).size.width / 5;
    final height = MediaQuery.of(context).size.height / 2.5;
    final radius = height / 1.7;
    final offsetLeft = radius * cos(angle - pi / 2) + circleCenterX - width / 2;
    final offsetTop = radius * sin(angle - pi / 2) + circleCenterY - height / 2;

    return Positioned(
      left: offsetLeft,
      top: offsetTop,
      child: Transform.rotate(
        angle: angle,
        child: SvgPicture.asset(
          RotatingMenu.menuAssetPaths[index],
          height: height,
        )
      )
    );
  }
}