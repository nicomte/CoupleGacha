enum MainMenuItem {
  checkRewards(
    'assets/check_rewards_heart.svg',
  ),
  playerSettings(
    'assets/player_settings_heart.svg',
  ),
  redeemPoints(
    'assets/redeem_points_heart.svg',
  ),
  selectChallenge(
    'assets/select_challenge_heart.svg',
  );

  final String assetPath;

  const MainMenuItem(this.assetPath);
}

class AssetsIndex {
  static const List<MainMenuItem> menuItems = [
    MainMenuItem.checkRewards,
    MainMenuItem.playerSettings,
    MainMenuItem.redeemPoints,
    MainMenuItem.selectChallenge,
  ];
}