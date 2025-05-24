import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';

class PlayerPointsDialog extends StatefulWidget {
  final Player player;

  const PlayerPointsDialog({Key? key, required this.player}) : super(key: key);

  @override
  State<PlayerPointsDialog> createState() => _PlayerPointsDialogState();
}

class _PlayerPointsDialogState extends State<PlayerPointsDialog> {
  Map<String, Map<String, double>> playerStats = {};

  @override
  void initState() {
    super.initState();
    playerStats = {
      'Keeper': {'stats': widget.player.keeper.toDouble(), 'increase': 0},
      'Defense': {'stats': widget.player.defense.toDouble(), 'increase': 0},
      'Passes': {'stats': widget.player.passes.toDouble(), 'increase': 0},
      'Playmaking': {
        'stats': widget.player.playmaking.toDouble(),
        'increase': 0
      },
      'Winger': {'stats': widget.player.winger.toDouble(), 'increase': 0},
      'Scoring': {'stats': widget.player.scoring.toDouble(), 'increase': 0},
      'Freekick': {'stats': widget.player.freekick.toDouble(), 'increase': 0},
    };
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
            title: Text(
              widget.player.userPointsAvailable.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
            Map<String, double> statValues = entry.value;
            double stats = statValues['stats']!;

            return ListTile(
              leading: Icon(
                iconStats,
                size: iconSizeMedium,
                color: Colors.green,
              ),
              title: Row(
                children: [
                  Text('$statName: '),
                  Text(
                    stats.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              subtitle: LinearProgressIndicator(
                value: stats / 100,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
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
