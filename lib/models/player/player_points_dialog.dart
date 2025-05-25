import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';

class PlayerUserPointsDialog extends StatefulWidget {
  final Player player;

  const PlayerUserPointsDialog({Key? key, required this.player})
      : super(key: key);

  @override
  State<PlayerUserPointsDialog> createState() => _PlayerUserPointsDialogState();
}

class _PlayerUserPointsDialogState extends State<PlayerUserPointsDialog> {
  Map<String, Map<String, double>> playerStats = {};
  int userPointsAvailable = 0;
  int userPointsUsed = 0;

  @override
  void initState() {
    super.initState();
    playerStats = {
      'Keeper': {'value': widget.player.keeper.toDouble(), 'increase': 0},
      // 'Defense': {'value': widget.player.defense.toDouble(), 'increase': 0},
      'Defense': {'value': 25.0, 'increase': 0},
      'Passes': {'value': widget.player.passes.toDouble(), 'increase': 0},
      'Playmaking': {
        'value': widget.player.playmaking.toDouble(),
        'increase': 0
      },
      'Winger': {'value': widget.player.winger.toDouble(), 'increase': 0},
      'Scoring': {'value': widget.player.scoring.toDouble(), 'increase': 0},
      'Freekick': {'value': widget.player.freekick.toDouble(), 'increase': 0},
    };

    userPointsAvailable = widget.player.userPointsAvailable.floor();
    userPointsUsed = 0;
  }

  @override
  Widget build(BuildContext context) {
    print('User points available2: $userPointsAvailable');
    return persoAlertDialogWithConstrainedContent(
      title: Text('Use training points for ${widget.player.getFullName()}'),
      content: Column(
        children: [
          /// Display the current user points available
          ListTile(
            leading: Icon(
              iconUser,
              size: iconSizeMedium,
              color: Colors.blue,
            ),
            title: Row(
              children: [
                Text(
                  userPointsAvailable.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (userPointsUsed > 0)
                  Text(
                    ' (-$userPointsUsed)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              'Number of user training points available',
              style: styleItalicBlueGrey,
            ),
            shape: shapePersoRoundedBorder(),
          ),

          /// Display the stats listtiles
          ...playerStats.entries.map((entry) {
            String statName = entry.key;
            double value = entry.value['value']!;
            int increase = entry.value['increase']!.toInt();

            return ListTile(
              leading: Icon(
                iconStats,
                size: iconSizeMedium,
                color: Colors.green,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('$statName: '),
                      Text(
                        value.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (increase > 0)
                        Text(
                          ' (+$increase)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      /// Decrease button
                      if (increase > 0)
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (value > 0) {
                                playerStats[statName]!['increase'] =
                                    increase - 1; // Decrease stat by 1
                                userPointsAvailable++;
                                userPointsUsed--;
                              }
                            });
                          },
                        ),

                      /// Increase button
                      if (userPointsAvailable > 0)
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              if (widget.player.userPointsAvailable > 0) {
                                playerStats[statName]!['increase'] =
                                    increase + 1; // Increase stat by 1
                                userPointsAvailable--;
                                userPointsUsed++;
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
              subtitle: Stack(
                children: [
                  /// Display the increased bar
                  LinearProgressIndicator(
                    value: (value + increase) / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),

                  /// Display the current value bar
                  LinearProgressIndicator(
                    value: value / 100,
                    backgroundColor: Colors.transparent,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ],
              ),
              shape: shapePersoRoundedBorder(),
            );
          }).toList(),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: persoCancelRow,
            ),
          ],
        ),
      ],
    );
  }
}
