import 'dart:math';

class Reward {
  final int id;
  final String text;
  final Rarity rarity;

  const Reward({required this.id, required this.text, required this.rarity});

  static final Random _random = Random();

  // Built once, cached for the lifetime of the app.
  static final Map<Rarity, List<int>> _rewardsByRarity = _groupByRarity();

  static Map<Rarity, List<int>> _groupByRarity() {
    final map = <Rarity, List<int>>{};
    for (final reward in rewards) {
      map.putIfAbsent(reward.rarity, () => []).add(reward.id);
    }
    return map;
  }

  static List<int> getRandomReward(int amountOfRewards) {
    List<int> rolledRewards = [];

    for (int i = 0; i < amountOfRewards; i++) {
      final Rarity rolledRarity = _pickRarity();
      final List<int> candidates = _rewardsByRarity[rolledRarity] ?? [];

      if (candidates.isEmpty) continue; // no rewards defined for that rarity

      final int rolledRewardId =
          candidates[_random.nextInt(candidates.length)];
      rolledRewards.add(rolledRewardId);
    }

    return rolledRewards;
  }

  // Cumulative weights — must sum to 100.
  static const List<MapEntry<Rarity, int>> _weights = [
    MapEntry(Rarity.loss, 50),
    MapEntry(Rarity.common, 20),
    MapEntry(Rarity.uncommon, 15),
    MapEntry(Rarity.rare, 10),
    MapEntry(Rarity.ultrarare, 5),
  ];

  static Rarity _pickRarity() {
    final int diceRoll = _random.nextInt(100); // 0..99
    int cumulative = 0;
    for (final entry in _weights) {
      cumulative += entry.value;
      if (diceRoll < cumulative) return entry.key;
    }
    return _weights.last.key; // unreachable if weights sum to 100
  }
}

enum Rarity { loss, common, uncommon, rare, ultrarare }

final rewards = [
  Reward(
    id: 1,
    text: "Reward 1 - This is a test for a reward with a rather long text.",
    rarity: Rarity.common,
  ),
  Reward(
    id: 2,
    text: "Reward 2 - This is a test for a reward with a rather long text.",
    rarity: Rarity.common,
  ),
  Reward(
    id: 3,
    text: "Reward 3 - This is a test for a reward with a rather long text.",
    rarity: Rarity.common,
  ),
  Reward(
    id: 4,
    text: "Reward 4 - This is a test for a reward with a rather long text.",
    rarity: Rarity.uncommon,
  ),
  Reward(
    id: 5,
    text: "Reward 5 - This is a test for a reward with a rather long text.",
    rarity: Rarity.uncommon,
  ),
  Reward(
    id: 6,
    text: "Reward 6 - This is a test for a reward with a rather long text.",
    rarity: Rarity.uncommon,
  ),
  Reward(
    id: 7,
    text: "Reward 7 - This is a test for a reward with a rather long text.",
    rarity: Rarity.rare,
  ),
  Reward(
    id: 8,
    text: "Reward 8 - This is a test for a reward with a rather long text.",
    rarity: Rarity.rare,
  ),
  Reward(
    id: 9,
    text: "Reward 9 - This is a test for a reward with a rather long text.",
    rarity: Rarity.rare,
  ),
  Reward(
    id: 10,
    text: "Reward 10 - This is a test for a reward with a rather long text.",
    rarity: Rarity.ultrarare,
  ),
  Reward(
    id: 11,
    text: "Reward 1 - This is a test for a reward with a rather long text.",
    rarity: Rarity.loss,
  ),
];
