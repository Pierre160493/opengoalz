import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'dart:math';

import '../classes/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> smileys = ['😊', '😁', '😄', '😃', '😆', '😅'];
    final String selectedSmiley = smileys[Random().nextInt(smileys.length)];

    final features = [
      player.keeper,
      player.defense,
      player.playmaking,
      player.passes,
      player.winger,
      player.scoring,
      player.freekick,
    ];

    return SizedBox(
      width: MediaQuery.of(context).size.width *
          0.8, // Adjust this value as needed
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${player.first_name} ${player.last_name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            child: Text(
                              selectedSmiley,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                              width:
                                  8), // Add some space between the avatar and the text
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'Age: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: player.age.toStringAsFixed(1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0), // Adjust this value as needed
                child: SizedBox(
                  width: 100, // Adjust this value as needed
                  height: 100, // Adjust this value as needed
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
