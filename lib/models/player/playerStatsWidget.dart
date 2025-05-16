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
  bool _showTrainingCoef = true;

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
          ListTile(
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
            shape: shapePersoRoundedBorder(
              Colors.green,
              2,
            ),
            trailing: Switch(
              value: _showTrainingCoef,
              onChanged: (value) {
                setState(() {
                  _showTrainingCoef = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget WidgetOtherStats() {
    final stats = [
      'Motivation',
      'Form',
      'Stamina',
      'Energy',
      'Experience',
      'Loyalty',
      'Leadership',
      'Discipline',
      'Communication',
      'Aggressivity',
      'Composure',
      'Teamwork',
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          moveHistoricDataListTile(),
          ListTile(
            leading: Icon(
              Icons.height,
              size: iconSizeMedium,
              color: Colors.green,
            ),
            title: Text(widget.player.size.toString()),
            subtitle: Text(
              'Player\'s size (in cm)',
              style: styleItalicBlueGrey,
            ),
            shape: shapePersoRoundedBorder(),
          ),
          for (var stat in stats)
            widget.player.getStatLinearWidget(
              stat,
              [
                if (listPlayerHistoricStats.isNotEmpty)
                  ...listPlayerHistoricStats
                      .map((s) => s[stat.toLowerCase()].toDouble())
                      .toList(),
                widget.player.toJson()[stat.toLowerCase()]
              ],
              _weekOffsetToCompareWithNow,
              context,
            ),
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
