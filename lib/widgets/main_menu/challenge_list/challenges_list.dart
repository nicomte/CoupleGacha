import 'package:couple_gacha/storage/active_challenges.dart';
import 'package:couple_gacha/storage/players.dart';
import 'package:couple_gacha/widgets/main_menu/challenge_list/challenge_list_entry.dart';
import 'package:couple_gacha/widgets/main_menu/challenge_list/challenges_list_title.dart';
import 'package:couple_gacha/domain/main_menu_enums.dart';
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

  @override
  State<ChallengesList> createState() => _ChallengesListState();
}

class _ChallengesListState extends State<ChallengesList> {

  @override
  Widget build(BuildContext context) {
    final challengesListSize = Size(
      widget.screenSize.width / 2,
      widget.screenSize.height / 2,
    );

    return Positioned(
      left: widget.screenSize.width - challengesListSize.width,
      child: SizedBox(
        width: challengesListSize.width,
        height: challengesListSize.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: challengesListSize.height * 0.05,
          children: [
            SizedBox(height: challengesListSize.height * 0.05),
            ChallengesListTitle(
              challengesListSize: challengesListSize,
              titleText: 'Active Challenges',
              textStyle: Theme.of(context).textTheme.headlineMedium!,
            ),
            ...activeChallenges.entries.map((entry)
              => ChallengesListEntry(
                challengesListSize: challengesListSize,
                entryText: entry.value,
                playerName: players[entry.key] ?? '',
                textStyle: Theme.of(context).textTheme.bodyMedium!,
                isHighlighted:
                    entry.key == widget.activeChallenge &&
                    widget.activeMenu == ActiveMenu.challengesList,
              ),
            )
          ],
        ),
      ),
    );
  }
}
