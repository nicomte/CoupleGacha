import 'package:couple_gacha/widgets/main_menu/challenge_list/challenge_list_entry.dart';
import 'package:couple_gacha/widgets/main_menu/challenge_list/challenges_list_title.dart';
import 'package:couple_gacha/widgets/main_menu/main_menu_enums.dart';
import 'package:flutter/material.dart';

class ChallengesList extends StatefulWidget {
  const ChallengesList({
    super.key,
    required this.screenSize,
    required this.activeChallenge,
    required this.activeMenu,
  });

  final Size screenSize;
  final int activeChallenge;
  final ActiveMenu activeMenu;

  static const List<(String, String)> _usersChallenges = [
    ('Player 1', 'test kurzer text'),
    (
      'Player 2',
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ',
    ),
  ];

  @override
  State<ChallengesList> createState() => _ChallengesListState();
}

class _ChallengesListState extends State<ChallengesList> {

  @override
  Widget build(BuildContext context) {
    final challengesListSize = Size(
      widget.screenSize.width / 3,
      widget.screenSize.height / 3,
    );

    return Positioned(
      left: widget.screenSize.width - challengesListSize.width,
      child: SizedBox(
        width: challengesListSize.width,
        height: challengesListSize.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ChallengesListTitle(
              challengesListSize: challengesListSize,
              titleText: 'Active Challenges',
              textStyle: Theme.of(context).textTheme.headlineMedium!,
            ),
            ...ChallengesList._usersChallenges.asMap().entries.map(
              (entry) => ChallengesListEntry(
                challengesListSize: challengesListSize,
                entryText: entry.value.$2,
                playerName: entry.value.$1,
                textStyle: Theme.of(context).textTheme.bodyMedium!,
                isHighlighted:
                    entry.key == widget.activeChallenge &&
                    widget.activeMenu == ActiveMenu.challengesList,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
