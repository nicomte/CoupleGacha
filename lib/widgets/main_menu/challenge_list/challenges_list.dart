import 'package:couple_gacha/widgets/main_menu/challenge_list/challenge_list_entry.dart';
import 'package:couple_gacha/widgets/main_menu/challenge_list/challenges_list_title.dart';
import 'package:flutter/material.dart';

class ChallengesList extends StatefulWidget {
  const ChallengesList({super.key, required this.screenSize});

  final Size screenSize;
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

  bool isHighlighted = false;
  @override
  Widget build(BuildContext context) {
    final challengesListSize = Size(
      widget.screenSize.width / 3,
      widget.screenSize.height / 2,
    );

    void toggleLength() {
      setState(() {
        isHighlighted = isHighlighted ? false : true;
        print(isHighlighted);
      });
    }

    return Positioned(
      left: widget.screenSize.width - challengesListSize.width,
      child: SizedBox(
        width: challengesListSize.width,
        height: challengesListSize.height,
        child: InkWell(
          onTap: toggleLength,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ChallengesListTitleEntry(
                challengesListSize: challengesListSize,
                titleText: 'Active Challenges',
                textStyle: Theme.of(context).textTheme.headlineMedium!,
              ),
              ChallengesListEntry(
                challengesListSize: challengesListSize,
                entryText: ChallengesList._usersChallenges[0].$2,
                textStyle: Theme.of(context).textTheme.bodyMedium!,
                playerName: '${ChallengesList._usersChallenges[0].$1} :',
                isHighlighted: isHighlighted,
              ),
              ChallengesListEntry(
                challengesListSize: challengesListSize,
                entryText: ChallengesList._usersChallenges[1].$2,
                textStyle: Theme.of(context).textTheme.bodyMedium!,
                playerName: '${ChallengesList._usersChallenges[1].$1} :'
              ),
            ],
          ),
        ),
      ),
    );
  }
}
