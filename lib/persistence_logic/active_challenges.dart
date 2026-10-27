import 'persistence.dart';

/// Tracks each player's active challenge.
/// Format: <activePlayerId, activeChallengeId>
/// Insertion order is preserved, so index access is stable.
class ActiveChallenges extends PersistentStore {
  final Map<int, int> _map = <int, int>{};

  @override
  String get fileName => 'active_challenges.json';

  // ---- read ----

  int get length => _map.length;

  /// Active challenge of a player, or null if none.
  int? challengeOf(int playerId) => _map[playerId];

  /// Entry (key = playerId, value = challengeId) at [index].
  MapEntry<int, int> entryAt(int index) {
    if (index < 0 || index >= _map.length) {
      throw RangeError.index(index, _map, 'index');
    }
    return _map.entries.elementAt(index);
  }

  bool hasActiveChallenge(int playerId) => _map.containsKey(playerId);
  bool isChallengeActive(int challengeId) => _map.containsValue(challengeId);

  /// Read-only snapshot, e.g. for ListView builders.
  List<MapEntry<int, int>> get entries => List.unmodifiable(_map.entries);

  // ---- write ----

  /// Sets (or replaces) the active challenge of a player.
  void add(int playerId, int challengeId) {
    _map[playerId] = challengeId;
    changed();
  }

  /// Removes the player's entry. Returns false if there was none.
  bool removeByPlayer(int playerId) {
    if (_map.remove(playerId) == null) return false;
    changed();
    return true;
  }

  /// Removes every entry whose value is [challengeId]
  /// (replaces the old entries.toList().firstWhere(...) one-liner).
  bool removeByChallenge(int challengeId) {
    final before = _map.length;
    _map.removeWhere((_, value) => value == challengeId);
    if (_map.length == before) return false;
    changed();
    return true;
  }

  // ---- json ----

  @override
  Object toJson() => _map.map((k, v) => MapEntry(k.toString(), v));

  @override
  void fromJson(Object json) {
    final parsed = (json as Map<String, dynamic>)
        .map((k, v) => MapEntry(int.parse(k), v as int));
    _map
      ..clear()
      ..addAll(parsed);
  }
}

final activeChallenges = ActiveChallenges();
