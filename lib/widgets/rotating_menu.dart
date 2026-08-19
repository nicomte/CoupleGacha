import 'package:couple_gacha/methods/element_utils.dart';
import 'package:couple_gacha/widgets/circle_geometry.dart';
import 'package:couple_gacha/widgets/heart_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math';

class RotatingMenu extends StatefulWidget {
  const RotatingMenu({
    super.key,
    required this.screenSize,
    required this.screenDiagonal
    });

  final Size screenSize;
  final double screenDiagonal;

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

class _RotatingMenuState extends State<RotatingMenu>
    with SingleTickerProviderStateMixin {
  int _rotatingOffset = 0;
  late final AnimationController _controller;
  late final Animation<double> _angleAnimation;

  static const double _stepAngle = pi / 2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _angleAnimation = Tween<double>(
      begin: 0,
      end: _stepAngle,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rotateMenuOptions() {
    _controller.forward(from: 0).then((_) {
      setState(() {
        _rotatingOffset =
            (_rotatingOffset - 1) % RotatingMenu.menuAssetPaths.length;
      });
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define menu item sizes, scaling and location
    final circleCenter = Offset(widget.screenSize.width / 4, widget.screenSize.height / 2);

    final centerHeartHeight = widget.screenDiagonal / 16;
    final centerHeartSize = sizeFromHeight(centerHeartHeight, 1.11630569161);

    final menuElementHeight = widget.screenDiagonal / 5.5;
    final menuElementSize = sizeFromHeight(menuElementHeight, 1.12487471524);

    final geometry = CircleGeometry(
      center: circleCenter,
      radius: widget.screenDiagonal * 0.1,
    );

    // Main element being built back to front: glow around selection, menu options, center heart
    return Scaffold(
      body: AnimatedBuilder(
        animation: _angleAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Selected heart glow
              HeartGlow(geometry: geometry, baseSize: menuElementSize),
              // Element options
              for (int i = 0; i < RotatingMenu.menuAssetPaths.length; i++)
                _buildMenuItem(
                  index: i,
                  geometry: geometry,
                  menuElementSize: menuElementSize,
                  animatedAngleOffset: _angleAnimation.value
                ),
              // Center heart
              Builder(
                builder: (context) {
                  final topLeft = topLeftFor(geometry.center, centerHeartSize);
                  return Positioned(
                    left: topLeft.dx,
                    top: topLeft.dy,
                    child: InkWell(
                      onTap: _rotateMenuOptions,
                      child: SvgPicture.asset(
                        RotatingMenu.centerHeart,
                        height: centerHeartSize.height,
                        width: centerHeartSize.width,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }
      )
    );
  }

  // Helper Widget to build individual menu options
  Widget _buildMenuItem({
    required int index,
    required CircleGeometry geometry,
    required Size menuElementSize,
    required double animatedAngleOffset
  }) {
    final assetIndex = (index + _rotatingOffset) % RotatingMenu.menuAssetPaths.length;
    // Location of current index "heart" on the circular menu in Radians
    final angle = (pi * index) / 2 + animatedAngleOffset;
    final itemCenter = geometry.pointAt(angle);
    final topLeft = topLeftFor(itemCenter, menuElementSize);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      child: Transform.rotate(
        angle: angle,
        child: SvgPicture.asset(
          RotatingMenu.menuAssetPaths[assetIndex],
          colorFilter: index == 1 && _angleAnimation.value == 0
              ? const ColorFilter.mode(
                  Color.fromARGB(30, 255, 255, 255),
                  BlendMode.srcATop,
                )
              : null,
          height: menuElementSize.height,
          width: menuElementSize.width,
        ),
      ),
    );
  }
}
