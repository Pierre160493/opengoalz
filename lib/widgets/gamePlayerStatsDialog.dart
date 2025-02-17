import 'package:flutter/material.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/game/gamePlayerStatsTab.dart';
import 'package:opengoalz/widgets/graphWidget.dart';

class GamePlayerStatsDialog extends StatelessWidget {
  final Game game;
  final int idPlayer;

  GamePlayerStatsDialog({required this.game, required this.idPlayer});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Player Stats'),
      content: FutureBuilder(
        future: fetchGamePlayerStats(game.id, idPlayer),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCircularAndText('Loading game player stats...');
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(
                child: Text('No game stats available for this player'));
          } else {
            final List<GamePlayerStat> gameStats =
                snapshot.data as List<GamePlayerStat>;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DataTable(
                  columns: [
                    DataColumn(
                        label: Text('Weights',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: TextDecoration.underline))),
                    DataColumn(
                        label: game.leftClub.getClubNameClickable(context)),
                    DataColumn(
                        label: game.rightClub.getClubNameClickable(context)),
                  ],
                  rows: [
                    _buildDataRow(context, 'Left Defense', gameStats,
                        (stat) => stat.weights.leftDefense),
                    _buildDataRow(context, 'Central Defense', gameStats,
                        (stat) => stat.weights.centralDefense),
                    _buildDataRow(context, 'Right Defense', gameStats,
                        (stat) => stat.weights.rightDefense),
                    _buildDataRow(context, 'Midfield', gameStats,
                        (stat) => stat.weights.midfield),
                    _buildDataRow(context, 'Left Attack', gameStats,
                        (stat) => stat.weights.leftAttack),
                    _buildDataRow(context, 'Central Attack', gameStats,
                        (stat) => stat.weights.centralAttack),
                    _buildDataRow(context, 'Right Attack', gameStats,
                        (stat) => stat.weights.rightAttack),
                  ],
                ),
              ],
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
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
          child: Text(title,
              style: TextStyle(decoration: TextDecoration.underline)),
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
}
