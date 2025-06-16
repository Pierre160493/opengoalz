import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/widgets/continent_display_widget.dart';

class CurrentRankingTab extends StatelessWidget {
  final League league;
  final bool isReturningBotClub;

  const CurrentRankingTab({
    Key? key,
    required this.league,
    this.isReturningBotClub = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int playedGamesCount =
        league.games.where((Game game) => game.dateEnd != null).length;
    // Consider making totalGamesInSeason a property of League or a global constant
    final int totalGamesInSeason = 30;
    final int percentagePlayed = totalGamesInSeason == 0
        ? 0
        : (100 * playedGamesCount / totalGamesInSeason).round();
    final String percentageText =
        percentagePlayed >= 100 ? 'Fully played' : '$percentagePlayed % played';

    return Column(
      children: [
        /// League presentation
        ListTile(
          leading: Icon(
            iconLeague,
            size: iconSizeMedium,
            color: Colors.green,
          ),
          shape: shapePersoRoundedBorder(Colors.green, 3),
          title: Text(
            league.getLeagueDescription(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          /// Season number and continent
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: Colors.green,
                  ),
                  Text(
                    'Season ${league.selectedSeasonNumber}: $percentageText',
                    style: styleItalicBlueGrey,
                  ),
                ],
              ),

              /// Continent
              ContinentRowWidget(
                continentName: league.continent,
                idMultiverse: league.idMultiverse,
              ),
            ],
          ),
        ),

        /// Separator with league percentage of advancement
        Container(
          margin: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  height: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'Rankings',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  height: 1,
                ),
              ),
            ],
          ),
        ),

        /// Rankings
        Expanded(
          // Removed redundant Container
          child: ListView.builder(
            itemCount: league.clubsLeague.length,
            itemBuilder: (context, index) {
              Club club = league.clubsLeague[index];

              return ListTile(
                shape: shapePersoRoundedBorder(),
                leading: Tooltip(
                  message: (() {
                    switch (index) {
                      case 0:
                        return league.level == 1
                            ? 'Plays International League'
                            : 'Plays First Barrage Games';
                      case 1:
                        return league.level == 1
                            ? 'Plays Second International League'
                            : 'Plays Second Barrage Game against 3rd of the opposite league';
                      case 2:
                        return league.level == 1
                            ? 'Plays Third International League'
                            : 'Plays Second Barrage Game against 2nd of the opposite league';
                      case 3:
                        return league.idLowerLeague == null
                            ? 'Plays Friendly Games Against Symetric League'
                            : 'Plays Against Winner of Second Barrage Games of lower leagues';
                      case 4:
                        return league.idLowerLeague == null
                            ? 'Plays Friendly Games Against Symetric League'
                            : 'Plays Against Loser of First Barrage Games of lower leagues';
                      case 5:
                        return league.idLowerLeague == null
                            ? 'Plays Friendly Games Against Symetric League'
                            : 'Plays Against Winner of First Barrage Games of lower leagues';
                      default:
                        return 'Rank ${index + 1}'; // Default message for other ranks
                    }
                  })(),
                  child: CircleAvatar(
                    backgroundColor: index == 0
                        ? Colors.yellow
                        : index == 1
                            ? Colors.grey
                            : index == 2
                                ? Colors.amber
                                : Colors.blue,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    club.getClubNameClickable(context),
                    club.getLastResultsWidget(context),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    club.getClubResultsVDLRow(),
                    club.getClubGoalsForAndAgainstRow()
                  ],
                ),
                onTap: () async {
                  if (isReturningBotClub) {
                    if (club.userName != null) {
                      context.showSnackBarError(
                          'The club already belongs to a user: ${club.userName}');
                    } else if (await context.showConfirmationDialog(
                            'Are you sure you want to select ${club.name} ?') ==
                        true) {
                      Navigator.pop(context, club);
                      return;
                    }
                  }
                },
                trailing: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text(
                    '${club.clubData.leaguePoints.toString()}',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
