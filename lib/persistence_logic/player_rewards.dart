import 'persistence.dart';

/// Rewards each player has gained.
/// Format: <playerId, <rewardId, amountOfThisReward>>
class PlayerRewards extends PersistentStore {
  final Map<int, Map<int, int>> _map = <int, Map<int, int>>{};

  @override
  String get fileName => 'player_rewards.json';

  // ---- read ----

  /// Read-only copy of a player's rewards (empty if the player has none).
  Map<int, int> rewardsOf(int playerId) =>
      Map.unmodifiable(_map[playerId] ?? const <int, int>{});

  /// How many of [rewardId] the player owns.
  int countOf(int playerId, int rewardId) => _map[playerId]?[rewardId] ?? 0;

  // ---- write ----

  /// Creates an empty reward tracker for a new player (keeps existing data).
  void createPlayer(int playerId) {
    if (_map.containsKey(playerId)) return;
    _map[playerId] = <int, int>{};
    changed();
  }

  /// Adds [amount] of one reward.
  void addReward(int playerId, int rewardId, [int amount = 1]) {
    addRewards(playerId, [rewardId], amount);
  }

  /// Adds every reward in [rewardIds] (+[amount] each) with a single save.
  void addRewards(int playerId, Iterable<int> rewardIds, [int amount = 1]) {
    final rewards = _map.putIfAbsent(playerId, () => <int, int>{});
    for (final id in rewardIds) {
      rewards.update(id, (count) => count + amount, ifAbsent: () => amount);
    }
    changed();
  }

  /// Removes up to [amount] of a reward; entries reaching 0 are deleted.
  /// Returns false if the player doesn't own enough.
  bool removeReward(int playerId, int rewardId, [int amount = 1]) {
    final rewards = _map[playerId];
    final owned = rewards?[rewardId] ?? 0;
    if (rewards == null || owned < amount) return false;
    if (owned == amount) {
      rewards.remove(rewardId);
    } else {
      rewards[rewardId] = owned - amount;
    }
    changed();
    return true;
  }

  /// Deletes all rewards of a player.
  void removePlayer(int playerId) {
    if (_map.remove(playerId) == null) return;
    changed();
  }

  // ---- json ----

  @override
  Object toJson() => _map.map((playerId, rewards) => MapEntry(
        playerId.toString(),
        rewards.map((rewardId, n) => MapEntry(rewardId.toString(), n)),
      ));

  @override
  void fromJson(Object json) {
    final parsed = (json as Map<String, dynamic>).map(
      (playerId, rewards) => MapEntry(
        int.parse(playerId),
        (rewards as Map<String, dynamic>)
            .map((rewardId, n) => MapEntry(int.parse(rewardId), n as int)),
      ),
    );
    _map
      ..clear()
      ..addAll(parsed);
  }
}

final playerRewards = PlayerRewards();
