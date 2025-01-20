import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerTrainingCoefDialogBox.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';

class PlayerCardStatsWidget extends StatefulWidget {
  final Player player;

  const PlayerCardStatsWidget({Key? key, required this.player})
      : super(key: key);

  @override
  _PlayerCardStatsWidgetState createState() => _PlayerCardStatsWidgetState();
}

class _PlayerCardStatsWidgetState extends State<PlayerCardStatsWidget> {
  late Stream<List<Map>> _playerHistoricStatsStream;
  int _playerHistoricStatsLength = 0; // Initialize with default value
  int _weekOffsetToCompareWithNow = 0; // Initialize with default value
  List<Map> listPlayerHistoricStats = [];
  bool _showTrainingCoef = false;

  @override
  void initState() {
    super.initState();

    _playerHistoricStatsStream = supabase
        .from('players_history_stats')
        .stream(primaryKey: ['id'])
        .eq('id_player', widget.player.id)
        .order('created_at', ascending: true);

    _listenToPlayerHistoricStream();
  }

  void _listenToPlayerHistoricStream() {
    _playerHistoricStatsStream.listen((data) {
      setState(() {
        listPlayerHistoricStats = data;
        _playerHistoricStatsLength = listPlayerHistoricStats.length;
        _weekOffsetToCompareWithNow =
            max(0, min(15, _playerHistoricStatsLength) - 1);
        print('Player historic stats: $_playerHistoricStatsLength');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(icon: iconHistory, text: 'Main Stats'),
              buildTabWithIcon(icon: Icons.query_stats, text: 'Other Stats'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                WidgetMainStats(),
                WidgetOtherStats(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget WidgetMainStats() {
    final statsNow = [
      widget.player.keeper,
      widget.player.defense,
      widget.player.passes,
      widget.player.playmaking,
      widget.player.winger,
      widget.player.scoring,
      widget.player.freekick,
    ];
    var statsHistoric = [];
    if (listPlayerHistoricStats.isNotEmpty && _weekOffsetToCompareWithNow > 0) {
      int index = listPlayerHistoricStats.length - _weekOffsetToCompareWithNow;
      statsHistoric = [
        listPlayerHistoricStats[index]['keeper'],
        listPlayerHistoricStats[index]['defense'],
        listPlayerHistoricStats[index]['passes'],
        listPlayerHistoricStats[index]['playmaking'],
        listPlayerHistoricStats[index]['winger'],
        listPlayerHistoricStats[index]['scoring'],
        listPlayerHistoricStats[index]['freekick'],
      ];
    }

    final maxStat = widget.player.trainingCoef.reduce(max);
    final List<double> statsTrainingCoef = widget.player.trainingCoef
        .map((coef) => 100 * coef / maxStat.toDouble())
        .toList();
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          moveHistoricDataListTile(),

          SizedBox(
            width: double.infinity,
            height: 240, // Adjust the height as needed
            child: RadarChart.dark(
              ticks: const [25, 50, 75, 100],
              features: const [
                'GoalKeeping',
                'Defending',
                'Passing',
                'PlayMaking',
                'Winger',
                'Scoring',
                'FreeKick',
              ],
              data: [
                statsNow,
                if (statsHistoric.isNotEmpty) statsHistoric.cast<num>(),
                if (_showTrainingCoef) statsTrainingCoef
              ],
              // graphColors: [Colors.green, Colors.red],
            ),
          ),

          /// Player training coefficients for training
          GestureDetector(
            onLongPress: () {
              setState(() {
                _showTrainingCoef = !_showTrainingCoef;
              });
            },
            child: ListTile(
              leading: Icon(
                iconStats,
                size: iconSizeMedium,
                color: Colors.green,
              ),
              title: Text(
                  'Points gained this season: ${widget.player.trainingPointsUsed.floor()}'),
              subtitle: Text(
                'Gain training points thanks to the staff',
                style: styleItalicBlueGrey,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PlayerTrainingDialog(player: widget.player);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget WidgetOtherStats() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          moveHistoricDataListTile(),
          widget.player.getStatLinearWidget(
              'Motivation',
              [
                if (listPlayerHistoricStats.isNotEmpty)
                  ...listPlayerHistoricStats
                      .map((stat) => stat['motivation'].toDouble())
                      .toList(),
                widget.player.motivation
              ],
              _weekOffsetToCompareWithNow,
              context),
          widget.player.getStatLinearWidget(
              'Form',
              [
                if (listPlayerHistoricStats.isNotEmpty)
                  ...listPlayerHistoricStats
                      .map((stat) => stat['form'].toDouble())
                      .toList(),
                widget.player.form
              ],
              _weekOffsetToCompareWithNow,
              context),
          widget.player.getStatLinearWidget(
              'Stamina',
              [
                if (listPlayerHistoricStats.isNotEmpty)
                  ...listPlayerHistoricStats
                      .map((stat) => stat['stamina'].toDouble())
                      .toList(),
                widget.player.stamina
              ],
              _weekOffsetToCompareWithNow,
              context),
          widget.player.getStatLinearWidget(
              'Energy',
              [
                if (listPlayerHistoricStats.isNotEmpty)
                  ...listPlayerHistoricStats
                      .map((stat) => stat['energy'].toDouble())
                      .toList(),
                widget.player.energy
              ],
              _weekOffsetToCompareWithNow,
              context),
          widget.player.getStatLinearWidget(
              'Experience',
              [
                if (listPlayerHistoricStats.isNotEmpty)
                  ...listPlayerHistoricStats
                      .map((stat) => stat['experience'].toDouble())
                      .toList(),
                widget.player.experience
              ],
              _weekOffsetToCompareWithNow,
              context),
        ],
      ),
    );
  }

  Widget moveHistoricDataListTile() {
    return ListTile(
      leading: Icon(
        iconHistory,
        size: iconSizeMedium,
        color: Colors.green,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _playerHistoricStatsLength > 0
                ? 'Player Stats History'
                : 'No Stats History',
            // style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Previous 7 weeks',
                icon: Icon(Icons.keyboard_double_arrow_left),
                onPressed: () {
                  setState(() {
                    _weekOffsetToCompareWithNow = min(
                        _playerHistoricStatsLength - 1,
                        _weekOffsetToCompareWithNow + 7);
                  });
                },
              ),
              IconButton(
                tooltip: 'Previous week',
                icon: Icon(Icons.keyboard_arrow_left),
                onPressed: () {
                  setState(() {
                    _weekOffsetToCompareWithNow = min(
                        _playerHistoricStatsLength - 1,
                        _weekOffsetToCompareWithNow + 1);
                  });
                },
              ),
              IconButton(
                tooltip: 'Next week',
                icon: Icon(Icons.keyboard_arrow_right),
                onPressed: () {
                  setState(() {
                    _weekOffsetToCompareWithNow =
                        max(0, _weekOffsetToCompareWithNow - 1);
                  });
                },
              ),
              IconButton(
                tooltip: 'Next 7 weeks',
                icon: Icon(Icons.keyboard_double_arrow_right),
                onPressed: () {
                  setState(() {
                    _weekOffsetToCompareWithNow =
                        max(0, _weekOffsetToCompareWithNow - 7);
                  });
                },
              ),
            ],
          ),
        ],
      ),
      subtitle: Text(
        _weekOffsetToCompareWithNow == 0
            ? 'No comparison'
            : _weekOffsetToCompareWithNow == 1
                ? 'Compare with last week'
                : 'Compare with ${_weekOffsetToCompareWithNow} weeks ago',
        style: styleItalicBlueGrey,
      ),
      shape: shapePersoRoundedBorder(),
    );
  }
}
