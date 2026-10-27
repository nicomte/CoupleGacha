import 'persistence.dart';

class Player {
  final int playerId;
  final String playerName;
  int points;

  Player({required this.playerId, required this.playerName, this.points = 0});

  Map<String, dynamic> toJson() =>
      {'id': playerId, 'name': playerName, 'points': points};

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        playerId: json['id'] as int,
        playerName: json['name'] as String,
        points: json['points'] as int? ?? 0,
      );
}

class PlayerStore extends PersistentStore {
  final List<Player> _players;

  PlayerStore(this._players);

  @override
  String get fileName => 'players.json';

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
    changed();
  }

  void subtractPoints(int playerId, int amount) {
    _findPlayer(playerId).points -= amount;
    changed();
  }

  void addPlayer(Player player) {
    _players.add(player);
    changed();
  }

  // ---- json ----

  @override
  Object toJson() => _players.map((p) => p.toJson()).toList();

  @override
  void fromJson(Object json) {
    final parsed = (json as List)
        .map((e) => Player.fromJson(e as Map<String, dynamic>))
        .toList();
    _players
      ..clear()
      ..addAll(parsed);
  }
}

final playerStore = PlayerStore([]);
