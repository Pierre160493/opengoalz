import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/postgresql_requests.dart';
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
    _initializeStats();
  }

  void _initializeStats() {
    playerStats = {
      'Keeper': {'value': widget.player.keeper.toDouble(), 'increase': 0},
      'Defense': {'value': widget.player.defense.toDouble(), 'increase': 0},
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

  void resetStats() {
    setState(() {
      _initializeStats(); // Reuse the initialization logic
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        value.toStringAsFixed(1),
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
                      IconButton(
                        icon: Icon(Icons.remove,
                            color: increase > 0 ? Colors.red : Colors.grey),
                        onPressed: increase > 0
                            ? () {
                                setState(() {
                                  if (value + increase > 0) {
                                    playerStats[statName]!['increase'] =
                                        increase - 1; // Decrease stat by 1
                                    userPointsAvailable++;
                                    userPointsUsed--;
                                  }
                                });
                              }
                            : null,
                      ),

                      /// Increase button
                      IconButton(
                        icon: Icon(Icons.add,
                            color: userPointsAvailable > 0
                                ? Colors.green
                                : Colors.grey),
                        onPressed: userPointsAvailable > 0
                            ? () {
                                setState(() {
                                  if (widget.player.userPointsAvailable > 0) {
                                    playerStats[statName]!['increase'] =
                                        increase + 1; // Increase stat by 1
                                    userPointsAvailable--;
                                    userPointsUsed++;
                                  }
                                });
                              }
                            : null,
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
            /// Cancel button
            TextButton(
              child: persoCancelRow,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            /// Reset button
            TextButton(
              child: persoRowWithIcon(
                Icons.refresh,
                'Reset',
                color: Colors.orange,
              ),
              onPressed: userPointsUsed > 0
                  ? () {
                      setState(() {
                        _initializeStats(); // Reset stats to initial values
                      });
                    }
                  : null,
            ),

            /// Confirm button
            TextButton(
              child: persoValidRow('Confirm using $userPointsUsed points'),
              onPressed: userPointsUsed > 0
                  ? () async {
                      // Prepare the array of increases in the correct order
                      final List<int> increases = [
                        playerStats['Keeper']!['increase']!.toInt(),
                        playerStats['Defense']!['increase']!.toInt(),
                        playerStats['Passes']!['increase']!.toInt(),
                        playerStats['Playmaking']!['increase']!.toInt(),
                        playerStats['Winger']!['increase']!.toInt(),
                        playerStats['Scoring']!['increase']!.toInt(),
                        playerStats['Freekick']!['increase']!.toInt(),
                      ];

                      bool isOk = await operationInDB(
                        context,
                        'FUNCTION',
                        'players_increase_stats_from_training_points',
                        data: {
                          'inp_id_player': widget.player.id,
                          'inp_increase_points': increases,
                          'inp_user_uuid': supabase.auth.currentUser!.id,
                        },
                        messageSuccess:
                            'Successfully used $userPointsUsed training points for ${widget.player.getFullName()}',
                      );
                      if (isOk) Navigator.of(context).pop();
                    }
                  : null,
            )
          ],
        ),
      ],
    );
  }
}
