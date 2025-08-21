import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/dialogs/player_user_points_dialog.dart';

class PlayerUserPointsButton extends StatelessWidget {
  final Player player;

  const PlayerUserPointsButton({Key? key, required this.player})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Use training points',
      icon: Icon(
        iconStats,
        // size: iconSizeMedium,
        color: colorIsMine,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return PlayerUserPointsDialog(player: player);
          },
        );
      },
      iconSize: iconSizeMedium,
      color: Colors.green,
    );
  }
}
