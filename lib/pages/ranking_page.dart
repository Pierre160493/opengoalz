import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/ranking.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class RankingPage extends StatefulWidget {
  final int idLeague; // Add idLeague as an input parameter
  const RankingPage({Key? key, required this.idLeague}) : super(key: key);

  static Route<void> route(int idLeague) {
    return MaterialPageRoute<void>(
      builder: (context) => RankingPage(idLeague: idLeague),
    );
  }

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late final Stream<List<Ranking>> _rankingStream;

  @override
  void initState() {
    _rankingStream =
        _fetchRankingStream(widget.idLeague); // Access idLeague via widget

    super.initState();
  }

  Stream<List<Ranking>> _fetchRankingStream(int idLeague) async* {
    // Use id_league to make the query
    var query = supabase
        .from('view_ranking')
        .stream(primaryKey: ['id_club'])
        .eq('id_league', idLeague)
        .order('n_points DESC')
        .order('total_goal_average');

    // Yield the result of the query
    yield* query
        .map((maps) => maps.map((map) => Ranking.fromMap(map)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings Page'),
      ),
      drawer: const AppDrawer(),
      body: MaxWidthContainer(
        child: StreamBuilder<List<Ranking>>(
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
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Pts')),
                      DataColumn(label: Text('+-')),
                      DataColumn(label: Text('W')),
                      DataColumn(label: Text('T')),
                      DataColumn(label: Text('L')),
                      DataColumn(label: Text('+')),
                      DataColumn(label: Text('-')),
                    ],
                    rows: rankings.take(8).map((ranking) {
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
                            Flexible(
                              child: Text(
                                ranking.nameClub,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(ranking.nPoints.toString())),
                          DataCell(Text(ranking.totalGoalAverage.toString())),
                          DataCell(Text(ranking.nVictories.toString())),
                          DataCell(Text(ranking.nDraws.toString())),
                          DataCell(Text(ranking.nDefeats.toString())),
                          DataCell(Text(ranking.goalsScored.toString())),
                          DataCell(Text(ranking.goalsTaken.toString())),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
