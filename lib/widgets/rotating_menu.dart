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

  static const centerHeart = 'assets/center_heart.svg';

  @override
  State<RotatingMenu> createState() => _RotatingMenuState();
}

class _RotatingMenuState extends State<RotatingMenu> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final circleCenterX = screenSize.width / 4;
    final circleCenterY = screenSize.height / 2;

    final centerHeartWidth = screenSize.width / 10;
    final centerHeartHeight = screenSize.height / 8;


    return Scaffold(
      body: Stack(
        children: [
          for (int i = 0; i < RotatingMenu.menuAssetPaths.length; i++) 
            _buildMenuItem(
              index: i,
              screenWidth: screenSize.width,
              screenHeight: screenSize.height,
              circleCenterX: circleCenterX,
              circleCenterY: circleCenterY
            ),
          Positioned(
            left: circleCenterX + centerHeartWidth / 6,
            top: circleCenterY - centerHeartHeight / 2,
            child: SvgPicture.asset(
              RotatingMenu.centerHeart,
              height: centerHeartHeight,
              width: centerHeartWidth,
            ),
          ) ,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required double screenWidth,
    required double screenHeight,
    required double circleCenterX,
    required double circleCenterY,
  }) {
    //final isSelected = index == selectedIndex;
    // Location of current index "heart" on the circular menu in Radians
    final angle = (pi * index) / 2;
    final menuElementWidth = screenWidth / 5;
    final menuElementHeight = screenHeight / 2;
    // Size of the circular menu. Pretty sensitive to changes
    final radius = menuElementHeight / 2;
    final offsetLeft = radius * cos(angle - pi / 2) + circleCenterX - menuElementWidth / 2;
    final offsetTop = radius * sin(angle - pi / 2) + circleCenterY - menuElementHeight / 2;

    return Positioned(
      left: offsetLeft,
      top: offsetTop,
      child: Transform.rotate(
        angle: angle,
        child: SvgPicture.asset(
          RotatingMenu.menuAssetPaths[index],
          height: menuElementHeight,
        )
      )
    );
  }
}