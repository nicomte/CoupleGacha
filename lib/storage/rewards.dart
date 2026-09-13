import 'dart:math';

class Reward {
  final int id;
  final String text;
  final Rarity rarity;

  const Reward({required this.id, required this.text, required this.rarity});
}

enum Rarity {
  loss(50),
  common(20),
  uncommon(15),
  rare(10),
  ultrarare(5);

  final int weight;
  const Rarity(this.weight);
}

class RewardCatalog {
  const RewardCatalog._();

  static const List<Reward> all = [
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

  static final Map<Rarity, List<int>> byRarity = _groupByRarity();

  static Map<Rarity, List<int>> _groupByRarity() {
    final map = <Rarity, List<int>>{};
    for (final reward in all) {
      map.putIfAbsent(reward.rarity, () => []).add(reward.id);
    }
    return map;
  }
}

class RewardRoller {
  const RewardRoller._();

  static final Random _random = Random();

  static List<int> roll(int amount) {
    final rolled = <int>[];
    for (int i = 0; i < amount; i++) {
      final rarity = _pickRarity();
      final candidates = RewardCatalog.byRarity[rarity] ?? const [];
      if (candidates.isEmpty) continue;
      rolled.add(candidates[_random.nextInt(candidates.length)]);
    }
    return rolled;
  }

  static Rarity _pickRarity() {
    final totalWeight = Rarity.values.fold<int>(0, (sum, r) => sum + r.weight);
    final diceRoll = _random.nextInt(totalWeight);
    int cumulative = 0;
    for (final rarity in Rarity.values) {
      cumulative += rarity.weight;
      if (diceRoll < cumulative) return rarity;
    }
    return Rarity.values.last; // unreachable
  }
}
