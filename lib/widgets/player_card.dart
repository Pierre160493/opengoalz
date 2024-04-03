import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'dart:math';

import '../classes/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final int number;

  const PlayerCard({Key? key, required this.player, required this.number})
      : super(key: key);

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
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30, // Adjust the width as needed
                            height: 30, // Adjust the height as needed
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Colors.blueGrey, // Change the color as needed
                            ),
                            child: Center(
                              child: Text(
                                '${number}.',
                                style: TextStyle(
                                  color: Colors
                                      .white, // Change the color of the text as needed
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              width:
                                  8), // Add some space between the circle and text
                          Text(
                            '${player.first_name[0]}.${player.last_name.toUpperCase()} ',
                          ),
                          player
                              .getStatusRow(), // Get status of the player (transfer, fired, injured, etc...)
                        ],
                      ),
                      const SizedBox(height: 6),
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: [
                                    const TextSpan(
                                      text: 'Age: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: player.age.toStringAsFixed(1),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: [
                                    const TextSpan(
                                      text: 'Country: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: 'FRANCE',
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: [
                                    const TextSpan(
                                      text: 'Average stats: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: player.avg_stats.toStringAsFixed(1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
