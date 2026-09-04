class Reward {
  final int id;
  final String text;
  final Rarity rarity;

  const Reward({required this.id, required this.text, required this.rarity});
}

enum Rarity {
  common,
  uncommon,
  rare,
  ultrarare
}

final rewards = [
  Reward(id: 1, text: "Reward 1 - This is a test for a reward with a rather long text.", rarity: Rarity.common),
  Reward(id: 2, text: "Reward 2 - This is a test for a reward with a rather long text.", rarity: Rarity.common),
  Reward(id: 3, text: "Reward 3 - This is a test for a reward with a rather long text.", rarity: Rarity.common),
  Reward(id: 4, text: "Reward 4 - This is a test for a reward with a rather long text.", rarity: Rarity.uncommon),
  Reward(id: 5, text: "Reward 5 - This is a test for a reward with a rather long text.", rarity: Rarity.uncommon),
  Reward(id: 6, text: "Reward 6 - This is a test for a reward with a rather long text.", rarity: Rarity.uncommon),
  Reward(id: 7, text: "Reward 7 - This is a test for a reward with a rather long text.", rarity: Rarity.rare),
  Reward(id: 8, text: "Reward 8 - This is a test for a reward with a rather long text.", rarity: Rarity.rare),
  Reward(id: 9, text: "Reward 9 - This is a test for a reward with a rather long text.", rarity: Rarity.rare),
  Reward(id: 10, text: "Reward 10 - This is a test for a reward with a rather long text.", rarity: Rarity.ultrarare),
];