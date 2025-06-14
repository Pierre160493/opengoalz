import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/widgets/continent_display_widget.dart'; // Import the new widget

class LeaguePageMainTab extends StatelessWidget {
  final League league;
  final int? selectedSeason;
  final bool isReturningBotClub;

  const LeaguePageMainTab({
    Key? key,
    required this.league,
    this.selectedSeason,
    this.isReturningBotClub = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int playedGamesCount =
        league.games.where((Game game) => game.dateEnd != null).length;
    final int totalGamesInSeason =
        30; // Assuming 30 games per season based on the division
    final int percentagePlayed =
        (100 * playedGamesCount / totalGamesInSeason).round();
    final String percentageText =
        percentagePlayed > 100 ? 'Fully played' : '$percentagePlayed % played';

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
                    'Season ${selectedSeason ?? league.seasonNumber}: $percentageText',
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
        Container(
          child: Expanded(
            child: ListView.builder(
              itemCount: league.clubsLeague.length,
              itemBuilder: (context, index) {
                print(
                    'LeagueMainTab: clubsLeague.length: ${league.clubsLeague.length}');
                Club club = league.clubsLeague[index];

                return ListTile(
                  shape: shapePersoRoundedBorder(),
                  // RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(
                  //       24), // Adjust border radius as needed
                  //   side: const BorderSide(
                  //     color: Colors.blueGrey, // Border color
                  //   ),
                  // ),
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
                          return 'Error';
                      }
                    })(),
                    child: CircleAvatar(
                      backgroundColor: index == 0
                          ? Colors.yellow
                          : index == 1
                              ? Colors.grey
                              : index == 2
                                  ? Colors.amber
                                  : Colors
                                      .blue, // Set the background color of the circleAvatar
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
                      Row(
                        children: [
                          Icon(Icons.emoji_events),
                          formSpacer3,
                          Text(
                            club.victories.toString(),
                            style: TextStyle(
                              color:
                                  Colors.green, // Set the text color to green
                              fontWeight: FontWeight.bold, // Make the text bold
                            ),
                          ),
                          Text(' / '),
                          Text(
                            club.draws.toString(),
                            style: TextStyle(
                              color: Colors.grey, // Set the text color to green
                              fontWeight: FontWeight.bold, // Make the text bold
                            ),
                          ),
                          Text(' / '),
                          Text(
                            club.defeats.toString(),
                            style: TextStyle(
                              color: Colors.red, // Set the text color to green
                              fontWeight: FontWeight.bold, // Make the text bold
                            ),
                          ),
                        ],
                      ),
                      Tooltip(
                        message: 'Goal Difference (Goals For / Against)',
                        child: Row(
                          children: [
                            Text(
                              club.goalsScored - club.goalsTaken > 0 ? '+' : '',
                              style: TextStyle(
                                color:
                                    Colors.grey, // Set the text color to green
                                fontWeight:
                                    FontWeight.bold, // Make the text bold
                              ),
                            ),
                            Text(
                              (club.goalsScored - club.goalsTaken).toString(),
                              style: TextStyle(
                                color:
                                    Colors.grey, // Set the text color to green
                                fontWeight:
                                    FontWeight.bold, // Make the text bold
                              ),
                            ),
                            Text(' ( '),
                            Text(
                              club.goalsScored.toString(),
                              style: TextStyle(
                                color:
                                    Colors.green, // Set the text color to green
                              ),
                            ),
                            Text(' / '),
                            Text(
                              club.goalsTaken.toString(),
                              style: TextStyle(
                                color:
                                    Colors.red, // Set the text color to green
                              ),
                            ),
                            Text(' )'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    /// If the page must return a CLub, return the clicked club
                    if (isReturningBotClub) {
                      if (club.userName != null)
                        context.showSnackBarError(
                            'The club already belongs to a user: ${club.userName}');
                      else if (await context.showConfirmationDialog(
                              'Are you sure you want to select ${club.name} ?') ==
                          true) {
                        Navigator.pop(context, club);
                        return;
                      }
                    }
                    // else
                    //   Navigator.push(
                    //     context,
                    //     ClubPage.route(club.id),
                    //   );
                  },
                  trailing: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Text(
                      '${club.points.toString()}',
                      style: TextStyle(color: Colors.black),
                    ),
                  ), // Display the index starting from 1
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
