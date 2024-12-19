import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerTrainingCoefDialogBox.dart';

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
  int _playerHistoricStatsToDisplay = 0; // Initialize with default value
  List<Map> listPlayerHistoricStats = [];

  @override
  void initState() {
    super.initState();

    _playerHistoricStatsStream = supabase
        .from('players_history_stats')
        .stream(primaryKey: ['id'])
        .eq('id_player', widget.player.id)
        .order('created_at');

    _listenToPlayerHistoricStats();
  }

  void _listenToPlayerHistoricStats() {
    _playerHistoricStatsStream.listen((data) {
      setState(() {
        listPlayerHistoricStats = data;
        _playerHistoricStatsLength = listPlayerHistoricStats.length;
        _playerHistoricStatsToDisplay = min(14, _playerHistoricStatsLength) - 1;
        print('Player historic stats: $_playerHistoricStatsLength');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
    if (listPlayerHistoricStats.isNotEmpty) {
      statsHistoric = [
        listPlayerHistoricStats[_playerHistoricStatsToDisplay]['keeper'],
        listPlayerHistoricStats[_playerHistoricStatsToDisplay]['defense'],
        listPlayerHistoricStats[_playerHistoricStatsToDisplay]['passes'],
        listPlayerHistoricStats[_playerHistoricStatsToDisplay]['playmaking'],
        listPlayerHistoricStats[_playerHistoricStatsToDisplay]['winger'],
        listPlayerHistoricStats[_playerHistoricStatsToDisplay]['scoring'],
        listPlayerHistoricStats[_playerHistoricStatsToDisplay]['freekick'],
      ];
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        setState(() {
                          _playerHistoricStatsToDisplay =
                              max(0, _playerHistoricStatsToDisplay - 1);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        setState(() {
                          _playerHistoricStatsToDisplay = min(
                              _playerHistoricStatsLength - 1,
                              _playerHistoricStatsToDisplay + 1);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            subtitle: Text(
              'Data from ${_playerHistoricStatsToDisplay + 1} weeks ago',
              style: styleItalicBlueGrey,
            ),
          ),

          widget.player.getStatLinearWidget(
              'Motivation',
              widget.player.motivation,
              listPlayerHistoricStats.isNotEmpty
                  ? listPlayerHistoricStats[_playerHistoricStatsToDisplay]
                          ['motivation']
                      .toDouble()
                  : null,
              context),
          widget.player.getStatLinearWidget(
              'Form',
              widget.player.form,
              listPlayerHistoricStats.isNotEmpty
                  ? listPlayerHistoricStats[_playerHistoricStatsToDisplay]
                          ['form']
                      .toDouble()
                  : null,
              context),
          widget.player.getStatLinearWidget(
              'Stamina',
              widget.player.stamina,
              listPlayerHistoricStats.isNotEmpty
                  ? listPlayerHistoricStats[_playerHistoricStatsToDisplay]
                          ['stamina']
                      .toDouble()
                  : null,
              context),
          widget.player.getStatLinearWidget(
              'Experience',
              widget.player.experience,
              listPlayerHistoricStats.isNotEmpty
                  ? listPlayerHistoricStats[_playerHistoricStatsToDisplay]
                          ['experience']
                      .toDouble()
                  : null,
              context),
          SizedBox(
            width: double.infinity,
            height: 240, // Adjust the height as needed
            child: RadarChart.dark(
              ticks: const [25, 50, 75, 100],
              // features: const [
              //   'GK',
              //   'DF',
              //   'PA',
              //   'PL',
              //   'WI',
              //   'SC',
              //   'FK',
              // ],
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
                if (statsHistoric.isNotEmpty) statsHistoric.cast<num>()
              ],
              // graphColors: [Colors.green, Colors.red],
            ),
          ),

          /// Player training coefficients for training
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
          ),
        ],
      ),
    );
  }
}
