import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/pages/league_page/league_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaguePageMainTab extends StatelessWidget {
  final League league;
  final bool isReturningBotClub;

  const LeaguePageMainTab({
    Key? key,
    required this.league,
    this.isReturningBotClub = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 6),

        /// Other leagues selection widget
        league.otherLeaguesSelectionWidget(context),

        /// Rankings
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
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'League ${(100 * league.games.where((Game game) => game.dateEnd != null).length / 30).round() > 100 ? 'Fully played' : (100 * league.games.where((Game game) => game.dateEnd != null).length / 30).round().toString() + ' % played'}',
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
          // decoration: BoxDecoration(
          //   border: Border.all(
          //     color: Colors.grey,
          //     width: 3,
          //   ),
          // ),
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

extension LeagueOtherLeaguesSelectionWidget on League {
  Widget otherLeaguesSelectionWidget(BuildContext context) {
    return Column(
      /// Upper League
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if (idUpperLeague != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaguePage(
                        idLeague: idUpperLeague!,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('No upper league for first division leagues'),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_circle_up, // Changed the icon
                    color: idUpperLeague == null
                        ? Colors.blueGrey
                        : Colors.green, // Changed the icon color
                  ),
                  Text('Upper League'),
                  Icon(
                    Icons.arrow_circle_up, // Changed the icon
                    color: idUpperLeague == null
                        ? Colors.blueGrey
                        : Colors.green, // Changed the icon color
                  ),
                ],
              ),
            ),
          ],
        ),

        /// Opposite and same level league button
        if (level != 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Same level league button (left)
              Container(
                // width: 160,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        if (level == 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'No same level league for first division leagues'),
                            ),
                          );
                        } else {
                          int leagueNumber = number == 1
                              ? (pow(2, level - 1)).toInt()
                              : number - 1;
                          try {
                            final response = await supabase
                                .from('leagues')
                                .select('id')
                                .eq('id_multiverse', idMultiverse)
                                .eq('season_number', seasonNumber)
                                .eq('continent', continent!)
                                .eq('level', level)
                                .eq('number', leagueNumber)
                                .limit(1)
                                .single();

                            if (response['error'] != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error fetching league: ${response['error']['message']}'),
                                ),
                              );
                            } else if (response['id'] != null) {
                              final idLowerLeague = response['id'];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LeaguePage(
                                    idLeague: idLowerLeague,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('No lower league found'),
                                ),
                              );
                            }
                          } on PostgrestException catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error fetching league: ${error.message}'),
                              ),
                            );
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                              'Left (${number - 1 == 0 ? pow(2, level - 1) : number - 1}/${pow(2, level - 1)})'),
                          Icon(
                            Icons.arrow_circle_left, // Changed the icon
                            color: level == 1
                                ? Colors.blueGrey
                                : Colors.green, // Changed the icon color
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// Opposite league button
              InkWell(
                onTap: () {
                  if (level > 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaguePage(
                          idLeague: -id,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'No opposite league for first division leagues'),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.compare_arrows, // Changed the icon
                      color: level == 1
                          ? Colors.blueGrey
                          : Colors.green, // Changed the icon color
                    ),
                    Text('Opposite'),
                    Icon(
                      Icons.compare_arrows, // Changed the icon
                      color: level == 1
                          ? Colors.blueGrey
                          : Colors.green, // Changed the icon color
                    ),
                  ],
                ),
              ),

              /// Same level league button (right)
              Container(
                // width: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (level == 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'No same level league for first division leagues'),
                            ),
                          );
                        } else {
                          int leagueNumber =
                              number == pow(2, level - 1) ? 1 : number + 1;
                          try {
                            final response = await supabase
                                .from('leagues')
                                .select('id')
                                .eq('id_multiverse', idMultiverse)
                                .eq('season_number', seasonNumber)
                                .eq('continent', continent!)
                                .eq('level', level)
                                .eq('number', leagueNumber)
                                .limit(1)
                                .single();

                            if (response['error'] != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error fetching league: ${response['error']['message']}'),
                                ),
                              );
                            } else if (response['id'] != null) {
                              final idLowerLeague = response['id'];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LeaguePage(
                                    idLeague: idLowerLeague,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('No lower league found'),
                                ),
                              );
                            }
                          } on PostgrestException catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error fetching league: ${error.message}'),
                              ),
                            );
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.arrow_circle_right, // Changed the icon
                            color: level == 1
                                ? Colors.blueGrey
                                : Colors.green, // Changed the icon color
                          ),
                          const SizedBox(width: 3),
                          Text(
                              'Right (${number + 1 > pow(2, level - 1) ? 1 : number + 1}/${pow(2, level - 1)})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        /// Lower Leagues
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () async {
                if (idLowerLeague != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaguePage(
                        idLeague: idLowerLeague!,
                      ),
                    ),
                  );
                } else {
                  context.showSnackBarError(
                      'No lower league for a last division league');
                }
              },
              child: Row(
                children: [
                  Text(
                    'Lower Left',
                    style: TextStyle(
                      color: idLowerLeague != null ? null : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_circle_down, // Changed the icon
                    color: idLowerLeague != null
                        ? Colors.green
                        : Colors.grey, // Changed the icon color
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                if (idLowerLeague != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaguePage(
                        idLeague: -idLowerLeague!,
                      ),
                    ),
                  );
                } else {
                  context.showSnackBarError(
                      'No lower league for a last division league');
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_circle_down, // Changed the icon
                    color: idLowerLeague != null
                        ? Colors.green
                        : Colors.grey, // Changed the icon color
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Lower Right',
                    style: TextStyle(
                      color: idLowerLeague != null ? null : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
