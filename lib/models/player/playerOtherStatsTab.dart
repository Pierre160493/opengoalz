import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/class/player.dart';

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
          player.getStatLinearWidget(
            stat,
            [
              if (listPlayerHistoricStats.isNotEmpty)
                ...listPlayerHistoricStats
                    .map((s) => s[stat.toLowerCase()].toDouble())
                    .toList(),
              player.toJson()[stat.toLowerCase()]
            ],
            _weekOffsetToCompareWithNow,
            context,
          ),
      ],
    ),
  );
}
