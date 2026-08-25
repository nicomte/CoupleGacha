import 'package:couple_gacha/methods/element_utils.dart';
import 'package:couple_gacha/widgets/main_menu/rotating_menu/circle_geometry.dart';
import 'package:couple_gacha/widgets/main_menu/rotating_menu/heart_glow.dart';
import 'package:couple_gacha/domain/main_menu_enums.dart';
import 'package:couple_gacha/widgets/main_menu/rotating_menu/assets_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math';

class RotatingMenu extends StatefulWidget {
  const RotatingMenu({
    super.key,
    required this.screenSize,
    required this.screenDiagonal,
    required this.rotatingMenuData,
    required this.activeMenu,
  });

  final Size screenSize;
  final double screenDiagonal;

  final ({int menuOffset, RotationDirection rotationDirection}) rotatingMenuData;

  final ActiveMenu activeMenu;

  static const _centerHeart = 'assets/center_heart.svg';

  @override
  State<RotatingMenu> createState() => _RotatingMenuState();
}

class _RotatingMenuState extends State<RotatingMenu>
    with SingleTickerProviderStateMixin {
  // This Widget gets the rotatingOffset, which defines the order of menu options, from it's parent.
  // To avoid immediate updates of the menu option positions, they actually base their position on _displayOffset.
  // The animation starts when the parent passes an updated rotatingOffset and only once the animation is over, does rotatingOffset get assigned to displayOffset.
  int _displayOffset = 0;
  late final AnimationController _controller;
  late final Animation<double> _animationProgress;

  static const double _stepAngle = (pi / 2);

  @override
  void initState() {
    super.initState();

    _displayOffset = widget.rotatingMenuData.menuOffset;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationProgress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant RotatingMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.rotatingMenuData.menuOffset !=
        widget.rotatingMenuData.menuOffset) {
      _rotateMenuOptions();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rotateMenuOptions() {
    if (_controller.value != 0.0) return;

    _controller.forward(from: 0).then((_) {

      setState(() {
        _displayOffset = widget.rotatingMenuData.menuOffset;
      });

      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define menu item sizes, scaling and location
    final circleCenter = Offset(
      widget.screenSize.width / 4,
      widget.screenSize.height / 2,
    );

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
        animation: _animationProgress,
        builder: (context, child) {
          return Stack(
            children: [
              // Selected heart glow
              HeartGlow(geometry: geometry, baseSize: menuElementSize),
              // Element options
              for (int i = 0; i < AssetsIndex.menuItems.length; i++)
                _buildMenuItem(
                  index: i,
                  geometry: geometry,
                  menuElementSize: menuElementSize,
                  animatedAngleOffset:
                      _animationProgress.value *
                      _stepAngle *
                      (widget.rotatingMenuData.rotationDirection ==
                              RotationDirection.clockwise
                          ? 1
                          : -1),
                ),
              // Center heart
              Builder(
                builder: (context) {
                  final topLeft = topLeftCentered(
                    geometry.center,
                    centerHeartSize,
                  );
                  return Positioned(
                    left: topLeft.dx,
                    top: topLeft.dy,
                    child: SvgPicture.asset(
                      RotatingMenu._centerHeart,
                      height: centerHeartSize.height,
                      width: centerHeartSize.width,
                    ),
                  );
                },
              ),
              Builder(
                builder: (_) {
                  final size = sizeFromHeight(
                    widget.screenDiagonal / 40,
                    3.57721578342,
                  );
                  final itemCenter = geometry.pointAt(pi / 2);
                  final topLeft = topLeftCentered(itemCenter, size);
                  return Positioned(
                    top: topLeft.dy,
                    left: topLeft.dx + widget.screenDiagonal / 7,
                    child: SvgPicture.asset(
                      'assets/heart_arrow.svg',
                      height: size.height,
                      width: size.width,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper Widget to build individual menu options
  Widget _buildMenuItem({
    required int index,
    required CircleGeometry geometry,
    required Size menuElementSize,
    required double animatedAngleOffset,
  }) {
    final assetIndex =
        (index + _displayOffset) % AssetsIndex.menuItems.length;

    final menuItem = AssetsIndex.menuItems[assetIndex];
    // Location of current index "heart" on the circular menu in Radians
    final angle = (pi * index) / 2 + animatedAngleOffset;
    final itemCenter = geometry.pointAt(angle);
    final topLeft = topLeftCentered(itemCenter, menuElementSize);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      child: Transform.rotate(
        angle: angle,
        child: SvgPicture.asset(
          menuItem.assetPath,
          colorFilter:
              index == 1 &&
                  !_controller.isAnimating &&
                  widget.activeMenu == ActiveMenu.rotatingMenu
              ? const ColorFilter.mode(
                  Color.fromARGB(125, 255, 255, 255),
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
