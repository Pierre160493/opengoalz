import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/player_stat_linear_widget.dart';

Widget WidgetOtherStats(BuildContext context, Player player,
    List<Map> listPlayerHistoricStats, int _weekOffsetToCompareWithNow) {
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
        for (var stat in stats)
          PlayerStatLinearTile(
            /// Player instance
            player: player,

            /// Stat label
            label: stat,

            /// List of stats history
            statsHistoryAll: [
              if (listPlayerHistoricStats.isNotEmpty)
                ...listPlayerHistoricStats
                    .map((s) => s[stat.toLowerCase()].toDouble())
                    .toList(),
              player.toJson()[stat.toLowerCase()]
            ],

            /// Week offset to compare with now
            weekOffsetToCompareWithNow: _weekOffsetToCompareWithNow,
          ),
      ],
    ),
  );
}
