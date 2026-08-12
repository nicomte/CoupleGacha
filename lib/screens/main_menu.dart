import 'package:couple_gacha/widgets/rotating_menu.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget{
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: RotatingMenu(),
  );
}