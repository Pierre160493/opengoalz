import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/widgets/graphWidget.dart';

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
                DataColumn(
                    label: Text('Weights',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: TextDecoration.underline))),
                DataColumn(label: game.leftClub.getClubNameClickable(context)),
                DataColumn(label: game.rightClub.getClubNameClickable(context)),
              ],
              rows: [
                _buildDataRow(
                    context,
                    'Left Defense',
                    gameStats,
                    (stat) => stat.weightsLeft.leftDefense,
                    (stat) => stat.weightsRight.leftDefense),
                _buildDataRow(
                    context,
                    'Central Defense',
                    gameStats,
                    (stat) => stat.weightsLeft.centralDefense,
                    (stat) => stat.weightsRight.centralDefense),
                _buildDataRow(
                    context,
                    'Right Defense',
                    gameStats,
                    (stat) => stat.weightsLeft.rightDefense,
                    (stat) => stat.weightsRight.rightDefense),
                _buildDataRow(
                    context,
                    'Midfield',
                    gameStats,
                    (stat) => stat.weightsLeft.midfield,
                    (stat) => stat.weightsRight.midfield),
                _buildDataRow(
                    context,
                    'Left Attack',
                    gameStats,
                    (stat) => stat.weightsLeft.leftAttack,
                    (stat) => stat.weightsRight.leftAttack),
                _buildDataRow(
                    context,
                    'Central Attack',
                    gameStats,
                    (stat) => stat.weightsLeft.centralAttack,
                    (stat) => stat.weightsRight.centralAttack),
                _buildDataRow(
                    context,
                    'Right Attack',
                    gameStats,
                    (stat) => stat.weightsLeft.rightAttack,
                    (stat) => stat.weightsRight.rightAttack),
              ],
            ),
          ],
        );
      }
    },
  );
}

DataRow _buildDataRow(
    BuildContext context,
    String title,
    List<GameStat> gameStats,
    double Function(GameStat) leftValue,
    double Function(GameStat) rightValue) {
  return DataRow(cells: [
    DataCell(
      InkWell(
        onTap: () {
          _showChartDialog(
            context,
            title,
            [
              gameStats.map(leftValue).toList(),
              gameStats.map(rightValue).toList(),
            ],
          );
        },
        child:
            Text(title, style: TextStyle(decoration: TextDecoration.underline)),
      ),
    ),
    DataCell(_getDataCellRow(
        context, title, gameStats.map(leftValue).toList(), Colors.blue)),
    DataCell(_getDataCellRow(
        context, title, gameStats.map(rightValue).toList(), Colors.red)),
  ]);
}

Widget _getDataCellRow(
    BuildContext context, String title, List<double> data, Color color) {
  double value = data.reduce((a, b) => a + b) / data.length;
  return ListTile(
    contentPadding: EdgeInsets.zero,
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
      _showChartDialog(context, title, [data]);
    },
  );
}

void _showChartDialog(
    BuildContext context, String title, List<List<num>> data) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final chartData = ChartData(
        title: title,
        yValues: data,
      );

      return ChartDialogBox(chartData: chartData);
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
  final PositionWeights weightsLeft;
  final PositionWeights weightsRight;

  GameStat({
    required this.id,
    required this.createdAt,
    this.idGame,
    required this.period,
    required this.minute,
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
