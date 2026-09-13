import 'package:flutter/foundation.dart';

class Player {
  final int playerId;
  final String playerName;
  int points;

  Player({
    required this.playerId,
    required this.playerName,
    this.points = 0,
  });
}

class PlayerStore extends ChangeNotifier {
  final List<Player> _players;

  PlayerStore(this._players);

  List<Player> get players => List.unmodifiable(_players);

  Player _findPlayer(int playerId) {
    return _players.firstWhere(
      (p) => p.playerId == playerId,
      orElse: () => throw ArgumentError('No player with id $playerId'),
    );
  }

  int pointsOf(int playerId) => _findPlayer(playerId).points;

  void addPoints(int playerId, int amount) {
    _findPlayer(playerId).points += amount;
    notifyListeners();
  }

  void subtractPoints(int playerId, int amount) {
    _findPlayer(playerId).points -= amount;
    notifyListeners();
  }
}

final playerStore = PlayerStore([
  Player(playerId: 8, playerName: 'Nico', points: 10),
  Player(playerId: 100, playerName: 'Monique', points: 10),
]);