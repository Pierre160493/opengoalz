import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';

Widget getGameStats(BuildContext context, Game game) {
  return DefaultTabController(
    length: 2,
    child: Column(
      children: [
        TabBar(
          tabs: [
            buildTabWithIcon(icon: Icons.preview, text: 'Game Stats'),
            buildTabWithIcon(icon: Icons.description, text: 'Player Stats'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              /// Game stats
              gameStatsWidget(game),

              /// Players stats
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.construction, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('Work in progress',
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    ),
  );
}

Widget gameStatsWidget(Game game) {
  return FutureBuilder(
    future: fetchGameStats(game.id),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData) {
        return Center(child: Text('No game stats available'));
      } else {
        final gameStats = snapshot.data as List<GameStat>;
        return Column(
          children: [
            DataTable(
              columns: [
                DataColumn(label: Text('Weights for')),
                DataColumn(label: Text(game.leftClub.name)),
                DataColumn(label: Text(game.rightClub.name)),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Left Defense')),
                  DataCell(_getDataCellRow(
                      context,
                      'Left Defense',
                      'Left Defense',
                      gameStats
                          .map((stat) => stat.weightsLeft.leftDefense)
                          .toList(),
                      Colors.blue)),
                  DataCell(_getDataCellRow(
                      context,
                      'Left Defense',
                      'Left Defense',
                      gameStats
                          .map((stat) => stat.weightsRight.leftDefense)
                          .toList(),
                      Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(
                    Text('Central Defense'),
                  ),
                  DataCell(_getDataCellRow(
                      context,
                      'Central Defense',
                      'Central Defense',
                      gameStats
                          .map((stat) => stat.weightsLeft.centralDefense)
                          .toList(),
                      Colors.blue)),
                  DataCell(_getDataCellRow(
                      context,
                      'Central Defense',
                      'Central Defense',
                      gameStats
                          .map((stat) => stat.weightsRight.centralDefense)
                          .toList(),
                      Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Right Defense')),
                  DataCell(_getDataCellRow(
                      context,
                      'Right Defense',
                      'Right Defense',
                      gameStats
                          .map((stat) => stat.weightsLeft.rightDefense)
                          .toList(),
                      Colors.blue)),
                  DataCell(_getDataCellRow(
                      context,
                      'Right Defense',
                      'Right Defense',
                      gameStats
                          .map((stat) => stat.weightsRight.rightDefense)
                          .toList(),
                      Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Midfield')),
                  DataCell(_getDataCellRow(
                      context,
                      'Midfield',
                      'Midfield',
                      gameStats
                          .map((stat) => stat.weightsLeft.midfield)
                          .toList(),
                      Colors.blue)),
                  DataCell(_getDataCellRow(
                      context,
                      'Midfield',
                      'Midfield',
                      gameStats
                          .map((stat) => stat.weightsRight.midfield)
                          .toList(),
                      Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Left Attack')),
                  DataCell(_getDataCellRow(
                      context,
                      'Left Attack',
                      'Left Attack',
                      gameStats
                          .map((stat) => stat.weightsLeft.leftAttack)
                          .toList(),
                      Colors.blue)),
                  DataCell(_getDataCellRow(
                      context,
                      'Left Attack',
                      'Left Attack',
                      gameStats
                          .map((stat) => stat.weightsRight.leftAttack)
                          .toList(),
                      Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Central Attack')),
                  DataCell(_getDataCellRow(
                      context,
                      'Central Attack',
                      'Central Attack',
                      gameStats
                          .map((stat) => stat.weightsLeft.centralAttack)
                          .toList(),
                      Colors.blue)),
                  DataCell(_getDataCellRow(
                      context,
                      'Central Attack',
                      'Central Attack',
                      gameStats
                          .map((stat) => stat.weightsRight.centralAttack)
                          .toList(),
                      Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Right Attack')),
                  DataCell(_getDataCellRow(
                      context,
                      'Right Attack',
                      'Right Attack',
                      gameStats
                          .map((stat) => stat.weightsLeft.rightAttack)
                          .toList(),
                      Colors.blue)),
                  DataCell(_getDataCellRow(
                      context,
                      'Right Attack',
                      'Right Attack',
                      gameStats
                          .map((stat) => stat.weightsRight.rightAttack)
                          .toList(),
                      Colors.red)),
                ]),
              ],
            ),
          ],
        );
      }
    },
  );
}

Widget _getDataCellRow(BuildContext context, String title,
    String tooltipMessage, List<double> data, Color color) {
  double value = data.reduce((a, b) => a + b) / data.length;
  return Tooltip(
    message: tooltipMessage,
    child: ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
      onTap: () {
        _showChartDialog(context, title, data);
      },
    ),
  );
}

void _showChartDialog(BuildContext context, String title, List<num> data) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final chartData = ChartData(
        title: title,
        yValues: data,
      );

      return PlayerLineChartDialogBox(chartData: chartData);
    },
  );
}

class PositionWeights {
  final double leftDefense;
  final double centralDefense;
  final double rightDefense;
  final double midfield;
  final double leftAttack;
  final double centralAttack;
  final double rightAttack;

  PositionWeights({
    required this.leftDefense,
    required this.centralDefense,
    required this.rightDefense,
    required this.midfield,
    required this.leftAttack,
    required this.centralAttack,
    required this.rightAttack,
  });

  PositionWeights.fromList(List<dynamic> listWeights)
      : leftDefense = listWeights[0].toDouble(),
        centralDefense = listWeights[1].toDouble(),
        rightDefense = listWeights[2].toDouble(),
        midfield = listWeights[3].toDouble(),
        leftAttack = listWeights[4].toDouble(),
        centralAttack = listWeights[5].toDouble(),
        rightAttack = listWeights[6].toDouble();
}

class GameStat {
  final int id;
  final DateTime createdAt;
  final int? idGame;
  final int period;
  final int minute;
  final int? extraTime;
  final PositionWeights weightsLeft;
  final PositionWeights weightsRight;

  GameStat({
    required this.id,
    required this.createdAt,
    this.idGame,
    required this.period,
    required this.minute,
    this.extraTime,
    required this.weightsLeft,
    required this.weightsRight,
  });

  factory GameStat.fromJson(Map<String, dynamic> json) {
    return GameStat(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      idGame: json['id_game'],
      period: json['period'],
      minute: json['minute'],
      extraTime: json['extra_time'],
      weightsLeft: PositionWeights.fromList(json['weights_left']),
      weightsRight: PositionWeights.fromList(json['weights_right']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'id_game': idGame,
      'period': period,
      'minute': minute,
      'extra_time': extraTime,
      'weights_left': weightsLeft,
      'weights_right': weightsRight,
    };
  }
}

Future<List<GameStat>> fetchGameStats(int idGame) async {
  final response = await supabase
      .from('games_stats')
      .select()
      .eq('id_game', idGame)
      .order('created_at', ascending: false);

  return List<GameStat>.from(response.map((json) => GameStat.fromJson(json)));
}
