import 'package:couple_gacha/widgets/circle_geometry.dart';
import 'package:couple_gacha/widgets/heart_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math';

class RotatingMenu extends StatefulWidget {
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
    final circleCenter = Offset(screenSize.width / 4, screenSize.height / 2);
    final diagonal = (sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2)));

    final centerHeartHeight = diagonal / 16;
    final centerHeartSize = sizeFromHeight(centerHeartHeight);

    final menuElementHeight = diagonal / 5.5;
    final menuElementSize = sizeFromHeight(menuElementHeight);

    final geometry = CircleGeometry(
      center: circleCenter,
      radius: diagonal * 0.1,
    );

    return Scaffold(
      body: Stack(
        children: [
          HeartGlow(
            geometry: geometry,
            baseSize: menuElementSize
          ),
          for (int i = 0; i < RotatingMenu.menuAssetPaths.length; i++)
            _buildMenuItem(
              index: i,
              geometry: geometry,
              menuElementSize: menuElementSize,
            ),
          Builder(
            builder: (context) {
              final topLeft = topLeftFor(geometry.center, centerHeartSize);
              return Positioned(
                left: topLeft.dx,
                top: topLeft.dy,
                child: SvgPicture.asset(
                  RotatingMenu.centerHeart,
                  height: centerHeartSize.height,
                  width: centerHeartSize.width,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required CircleGeometry geometry,
    required Size menuElementSize,
  }) {
    // Location of current index "heart" on the circular menu in Radians
    final angle = (pi * index) / 2;
    final itemCenter = geometry.pointAt(angle);
    final topLeft = topLeftFor(itemCenter, menuElementSize);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      child: Transform.rotate(
        angle: angle,
        child: SvgPicture.asset(
          RotatingMenu.menuAssetPaths[index],
          colorFilter: index == 1 ? const ColorFilter.mode(Color.fromARGB(30, 255, 255, 255), BlendMode.srcATop) : null,
          height: menuElementSize.height,
          width: menuElementSize.width,
        ),
      ),
    );
  }
}
