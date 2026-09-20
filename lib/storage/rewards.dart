import 'dart:math';

import 'package:flutter/material.dart';

class Reward {
  final int id;
  final String text;
  final Rarity rarity;

  const Reward({required this.id, required this.text, required this.rarity});
}

enum Rarity {
  loss(50,Color(0xfffae8ed), Color(0xffff4a98)),
  common(20, Color(0xff5edc1f), Color.fromARGB(255, 176, 248, 137)),
  uncommon(15, Color(0xff1a43bf), Color.fromARGB(255, 162, 184, 255)),
  rare(10, Color(0xffb026ff), Color.fromARGB(255, 218, 165, 255)),
  ultrarare(5, Color(0xfff2003c), Color.fromARGB(255, 255, 164, 184));

  final int weight;
  final Color borderColor;
  final Color fillColor;
  const Rarity(this.weight, this.borderColor, this.fillColor);
}

class RewardCatalog {
  const RewardCatalog._();

  static final Map<int, Reward> _byId = {
    for (final reward in all) reward.id: reward,
  };

  /// Returns the reward with [id]. Throws if it doesn't exist.
  static Reward getById(int id) {
    final reward = _byId[id];
    if (reward == null) throw ArgumentError.value(id, 'id', 'Unknown reward id');
    return reward;
  }

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
