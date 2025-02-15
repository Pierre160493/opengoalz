import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/gameWeights.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:opengoalz/widgets/gamePlayerStatsDialog.dart';

Widget gamePlayerStatsWidget(BuildContext context, Game game, int idPlayer) {
  return ElevatedButton(
    onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GamePlayerStatsDialog(game: game, idPlayer: idPlayer);
        },
      );
    },
    child: Text('Show Player Stats'),
  );
}

DataRow _buildDataRow(BuildContext context, String title,
    List<GamePlayerStat> gameStats, double Function(GamePlayerStat) value) {
  return DataRow(cells: [
    DataCell(
      InkWell(
        onTap: () {
          _showChartDialog(
            context,
            title,
            [
              gameStats.map(value).toList(),
            ],
          );
        },
        child:
            Text(title, style: TextStyle(decoration: TextDecoration.underline)),
      ),
    ),
    DataCell(_getDataCellRow(
        context, title, gameStats.map(value).toList(), Colors.blue)),
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

class GamePlayerStat {
  final int id;
  final DateTime createdAt;
  final int? idGame;
  final int idPlayer;
  final int period;
  final int minute;
  final GameWeights weights;
  final int position;
  final double sumWeights;

  GamePlayerStat({
    required this.id,
    required this.createdAt,
    this.idGame,
    required this.idPlayer,
    required this.period,
    required this.minute,
    required this.weights,
    required this.position,
    required this.sumWeights,
  });

  factory GamePlayerStat.fromJson(Map<String, dynamic> json) {
    return GamePlayerStat(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      idGame: json['id_game'],
      idPlayer: json['id_player'],
      period: json['period'],
      minute: json['minute'],
      weights: GameWeights.fromList(json['weights']),
      position: json['position'],
      sumWeights: json['sum_weights'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'id_game': idGame,
      'id_player': idPlayer,
      'period': period,
      'minute': minute,
      'weights': weights,
      'position': position,
      'sum_weights': sumWeights,
    };
  }
}

Future<List<GamePlayerStat>> fetchGamePlayerStats(
    int idGame, int idPlayer) async {
  final response = await supabase
      .from('game_player_stats_all')
      .select()
      .eq('id_game', idGame)
      .eq('id_player', idPlayer);

  return List<GamePlayerStat>.from(
      response.map((json) => GamePlayerStat.fromJson(json)));
}
