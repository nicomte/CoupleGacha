class Player {
  final int playerId;
  final String playerName;
  int points;

  Player({
    required this.playerId,
    required this.playerName,
    this.points = 0,
  });

  

  // Optional: increment points
  void addPoints(int additionalPoints) {
    points += additionalPoints;
  }

}

final players = [
    Player(playerId: 8, playerName: 'Nico', points: 0),
    Player(playerId: 100, playerName: 'Monique', points: 0),
  ];