import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'dart:math';

import '../classes/player.dart';

class PlayerCardSingle extends StatelessWidget {
  final Player player;

  const PlayerCardSingle({Key? key, required this.player}) : super(key: key);

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
      width: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player's name row
              Row(
                children: [
                  Text(
                    '${player.first_name} ${player.last_name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20, // Increase the font size here
                    ),
                  ),
                  const Spacer(), // Add Spacer widget to push CircleAvatar to the right
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      selectedSmiley,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ],
              ),
              if (player.date_firing != null)
                Row(
                  children: [
                    const SizedBox(
                      width: 24,
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Will be fired in:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text:
                                ' ${player.date_firing!.difference(DateTime.now()).inDays.toString()} days',
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.normal, // Remove bold font weight
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const SizedBox(
                    width: 24,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Age: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: player.age.toStringAsFixed(2),
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.normal, // Remove bold font weight
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const SizedBox(
                    width: 24,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Club: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: player.club_name,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.normal, // Remove bold font weight
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
//               if (player.date_end_injury != null) {
//   SizedBox(
//     height: 24, // Add spacing between name and radar chart
//   ),
// }
              const SizedBox(
                  height: 24), // Add spacing between name and radar chart
              // Radar chart
              SizedBox(
                width: double.infinity, // Make radar chart fill available width
                height: 200, // Adjust this value as needed
                child: RadarChart.dark(
                  ticks: const [25, 50, 75, 100],
                  features: const [
                    'Keeper',
                    'Defense',
                    'Passes',
                    'Playmaking',
                    'Winger',
                    'Scoring',
                    'Freekick',
                  ],
                  data: [features],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
