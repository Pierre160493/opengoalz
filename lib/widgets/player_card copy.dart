import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

import '../classes/player/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final int number;

  const PlayerCard({Key? key, required this.player, required this.number})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final features = [
      player.keeper,
      player.defense,
      player.playmaking,
      player.passes,
      player.winger,
      player.scoring,
      player.freekick,
    ];

    return Card(
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(3.0),
        leading: Container(
          width: 30, // Adjust the width as needed
          height: 30, // Adjust the height as needed
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueGrey, // Change the color as needed
          ),
          child: Center(
            child: Text(
              '${number}.',
              style: TextStyle(
                color: Colors.white, // Change the color of the text as needed
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                '${player.first_name[0]}.${player.last_name.toUpperCase()} ',
                overflow: TextOverflow
                    .ellipsis, // Handles overflow by displaying "..."
                maxLines: 1, // Limits to one line
              ),
            ),
            player
                .getStatusRow(), // Get status of the player (transfer, fired, injured, etc...)
          ],
        ),
        subtitle: Column(
          children: [
            player.getAgeWidget(),
            player.getAvgStatsWidget(),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Icon(
                        Icons.person_pin_outlined,
                        size: 48,
                      ),
                    ),
                    SizedBox(
                        width:
                            8), // Add some space between the avatar and the text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        player.getAgeWidget(),
                        player.getCountryWidget(),
                        player.getAvgStatsWidget(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 120, // Adjust this value as needed
                  height: 120, // Adjust this value as needed
                  child: RadarChart.dark(
                    ticks: const [25, 50, 75, 100],
                    features: const [
                      'GK',
                      'DF',
                      'PA',
                      'PL',
                      'WI',
                      'SC',
                      'FK',
                    ],
                    data: [features],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
