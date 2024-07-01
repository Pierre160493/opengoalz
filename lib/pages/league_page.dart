import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/league.dart';
import 'package:opengoalz/classes/ranking.dart';
import 'package:opengoalz/game/class/gameClass.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';

class LeaguePage extends StatefulWidget {
  final int idLeague; // Add idLeague as an input parameter
  const LeaguePage({Key? key, required this.idLeague}) : super(key: key);

  static Route<void> route(int idLeague) {
    return MaterialPageRoute<void>(
      builder: (context) => LeaguePage(idLeague: idLeague),
    );
  }

  @override
  State<LeaguePage> createState() => _RankingPageState();
}

class _RankingPageState extends State<LeaguePage> {
  Stream<League> _leagueStream = Stream.empty();
  // late Stream<GameClass> _gameStream;
  late final Stream<List<Ranking>> _rankingStream;

  @override
  void initState() {
    // Fetch the league data
    _leagueStream = supabase
        .from('leagues')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idLeague) // Access idLeague via widget
        .map((maps) => maps.map((map) => League.fromMap(map)).first);

    _rankingStream = supabase
        .from('view_ranking')
        .stream(primaryKey: ['id_club'])
        .eq('id_league', widget.idLeague)
        .map((maps) => maps
            .map((map) => Ranking.fromMap(map))
            .toList()); // Access idLeague via widget

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<League>(
        stream: _leagueStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('ERROR: ${snapshot.error}'),
            );
          } else {
            League league = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                    'League ${league.level.toString()}.${league.number.toString()} of ${league.continent}'),
              ),
              drawer: const AppDrawer(),
              body: MaxWidthContainer(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Rankings'),
                          Tab(text: 'Games'),
                          Tab(text: 'Stats'),
                          Tab(text: 'Chat'),
                        ],
                      ),
                      Expanded(
                          child: TabBarView(
                        children: [
                          _RankingPage(league, context),
                          Text('Games Tab'),
                          Text('Stats Tab'),
                          Text('League Chat'),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }

  Widget _RankingPage(League league, BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 6),

        /// Season row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: Colors.blueGrey,
                  size: 36,
                ),
                SizedBox(width: 8),
                Text(
                  'Season ${league.seasonNumber.toString()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (league.idPreviousSeason != null)
              Row(
                children: [
                  // SizedBox(width: 64),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        LeaguePage.route(league.idPreviousSeason!),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.keyboard_double_arrow_left),
                        Text('Previous Season'),
                      ],
                    ),
                  ),
                ],
              )
          ],
        ),

        /// Upper and opposite league button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 180,
              child: Text('Upper League'),
            ),
            InkWell(
              onTap: () {
                if (league.idUpperLeague != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaguePage(
                        idLeague: league.idUpperLeague!,
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
              child: Icon(
                Icons.arrow_circle_up, // Changed the icon
                color: league.idUpperLeague == null
                    ? Colors.blueGrey
                    : Colors.green, // Changed the icon color
                size: 32, // Increased the icon size
              ),
            ),
            SizedBox(width: 32),
            InkWell(
              onTap: () async {
                try {
                  final response = await supabase
                      .from('leagues')
                      .select('id')
                      .eq('id_upper_league', league.id)
                      .gt('id', 0)
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
                    print(response['id']);
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
                      content: Text('Error fetching league: ${error.message}'),
                    ),
                  );
                }
              },
              child: Icon(
                Icons.arrow_circle_down, // Changed the icon
                color: Colors.green, // Changed the icon color
                size: 32, // Increased the icon size
              ),
            ),
            InkWell(
              onTap: () async {
                try {
                  final response = await supabase
                      .from('leagues')
                      .select('id')
                      .eq('id_upper_league', league.id)
                      .gt('id', 0)
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
                    print(response['id']);
                    final idLowerLeague = response['id'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaguePage(
                          idLeague: -idLowerLeague,
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
                      content: Text('Error fetching league: ${error.message}'),
                    ),
                  );
                }
              },
              child: Icon(
                Icons.arrow_circle_down, // Changed the icon
                color: Colors.green, // Changed the icon color
                size: 32, // Increased the icon size
              ),
            ),
            Container(
              width: 180,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Lower Leagues'),
              ),
            ),
          ],
        ),

        /// Opposite and same level league button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Opposite league button
            Container(
              width: 180,
              child: Text('Opposite League'),
            ),
            InkWell(
              onTap: () {
                if (league.level > 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaguePage(
                        idLeague: -league.id,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('No opposite league for first division leagues'),
                    ),
                  );
                }
              },
              child: Icon(
                Icons.compare_arrows, // Changed the icon
                color: league.level == 1
                    ? Colors.blueGrey
                    : Colors.green, // Changed the icon color
                size: 32, // Increased the icon size
              ),
            ),
            SizedBox(width: 32),

            /// Same level league button (left)
            InkWell(
              onTap: () async {
                if (league.level == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'No same level league for first division leagues'),
                    ),
                  );
                } else {
                  int leagueNumber = league.number == 1
                      ? (pow(2, league.level - 1)).toInt()
                      : league.number - 1;
                  try {
                    print('Current league level:' + league.level.toString());
                    print('Current league number:' + league.level.toString());
                    print(league.level);
                    print(leagueNumber);
                    final response = await supabase
                        .from('leagues')
                        .select('id')
                        .eq('multiverse_speed', league.multiverseSpeed)
                        .eq('season_number', league.seasonNumber)
                        .eq('continent', league.continent)
                        .eq('level', league.level)
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
                      print(response['id']);
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
                        content:
                            Text('Error fetching league: ${error.message}'),
                      ),
                    );
                  }
                }
              },
              child: Icon(
                Icons.arrow_circle_left, // Changed the icon
                color: league.level == 1
                    ? Colors.blueGrey
                    : Colors.green, // Changed the icon color
                size: 32, // Increased the icon size
              ),
            ),

            /// Same level league button (right)
            InkWell(
              onTap: () async {
                if (league.level == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'No same level league for first division leagues'),
                    ),
                  );
                } else {
                  int leagueNumber = league.number == pow(2, league.level - 1)
                      ? 1
                      : league.number + 1;
                  try {
                    final response = await supabase
                        .from('leagues')
                        .select('id')
                        .eq('multiverse_speed', league.multiverseSpeed)
                        .eq('season_number', league.seasonNumber)
                        .eq('continent', league.continent)
                        .eq('level', league.level)
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
                      print(response['id']);
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
                        content:
                            Text('Error fetching league: ${error.message}'),
                      ),
                    );
                  }
                }
              },
              child: Icon(
                Icons.arrow_circle_right, // Changed the icon
                color: league.level == 1
                    ? Colors.blueGrey
                    : Colors.green, // Changed the icon color
                size: 32, // Increased the icon size
              ),
            ),
            Container(
              width: 180,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                    'Same level Leagues (${league.number}/${pow(2, league.level - 1)})'),
              ),
            ),
          ],
        ),

        /// Rankings tables
        StreamBuilder<List<Ranking>>(
          stream: _rankingStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('ERROR: ${snapshot.error}'),
              );
            } else {
              final rankings = snapshot.data ?? [];
              if (rankings.isEmpty) {
                return const Center(
                  child: Text('ERROR: No rankings found'),
                );
              } else {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Pos')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Points')),
                      DataColumn(label: Text('Goal Diff')),
                    ],
                    rows: rankings.take(6).map((ranking) {
                      final index = rankings.indexOf(ranking) + 1;
                      var color = index.isOdd ? Colors.blueGrey : null;
                      if (ranking.idClub ==
                          Provider.of<SessionProvider>(context)
                              .selectedClub
                              .id_club) color = Colors.green;
                      return DataRow(
                        color: WidgetStateProperty.all(color),
                        onSelectChanged: (_) {
                          Navigator.push(
                            context,
                            ClubPage.route(ranking.idClub),
                          );
                        },
                        cells: [
                          DataCell(Text(index.toString())),
                          DataCell(
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: 120, // Set the maximum width here
                              ),
                              child: Flexible(
                                child: Text(ranking.nameClub,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            ),
                          ),

                          DataCell(Row(
                            children: [
                              Text(
                                ranking.nPoints.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(' '),
                              Container(
                                padding: EdgeInsets.all(4),
                                color: Colors
                                    .black, // Set the background color here
                                child: Row(
                                  children: [
                                    Text(
                                      ranking.nVictories.toString(),
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(' / '),
                                    Text(
                                      ranking.nDraws.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(' / '),
                                    Text(
                                      ranking.nDefeats.toString(),
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                          // DataCell(Text(ranking.totalGoalAverage.toString())),
                          DataCell(Row(
                            children: [
                              Text(
                                ranking.totalGoalAverage.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(' '),
                              Container(
                                padding: EdgeInsets.all(4),
                                color: Colors
                                    .black, // Set the background color here
                                child: Row(
                                  children: [
                                    Text(
                                      ranking.goalsScored.toString(),
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(' / '),
                                    Text(
                                      ranking.goalsTaken.toString(),
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
