class Challenge {
  const Challenge({
    required this.challengeId,
    required this.challengeText,
    required this.challengePoints,
    required this.challengeCategory
  });

  final int challengeId;
  final String challengeText;
  final int challengePoints;
  final String challengeCategory;
}

enum ChallengeCategory {
  game,
  question,
  activity,
  creative;

  String category(){
    switch(this){
      case ChallengeCategory.game:
        return 'Games';
      case ChallengeCategory.question:
        return 'Questions';
      case ChallengeCategory.activity:
        return 'Activities';
      case ChallengeCategory.creative:
        return 'Creative';
    }
  }
}

final challenges = [
  Challenge(
    challengeId: 1,
    challengeText: 'Beat Tree Sentinel without levelling up.',
    challengePoints: 100,
    challengeCategory: ChallengeCategory.game.category()
  ),
  Challenge(
    challengeId: 2,
    challengeText: 'Write Story about Partner with theme Medieval',
    challengePoints: 50,
    challengeCategory: ChallengeCategory.creative.category()
  ),
    Challenge(
    challengeId: 3,
    challengeText: 'Plan walk to location.',
    challengePoints: 5,
    challengeCategory: ChallengeCategory.activity.category()
  ),
];
