import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/player_user_points_button.dart';
import 'package:opengoalz/models/player/player_user_points_dialog.dart';

class PlayerUserPointsListTile extends StatelessWidget {
  final Player player;

  const PlayerUserPointsListTile({Key? key, required this.player})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// If the player is not an embodied player
    if (player.userName == null) {
      return ListTile(
        shape: shapePersoRoundedBorder(),
        leading: Icon(
          iconUser,
          size: iconSizeMedium,
          color: Colors.blue,
        ),
        title: Text(
          'Player not embodied',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'No user assigned',
          style: styleItalicBlueGrey,
        ),
      );
    }

    return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Icon(
        iconUser,
        size: iconSizeMedium,
        color: colorIsMine,
      ),
      title: Row(
        children: [
          Text('User training points available: '),
          Text(
            player.userPointsAvailable.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: player.userPointsAvailable < 0 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text('User training points used: ', style: styleItalicBlueGrey),
          Text(
            player.userPointsUsed.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
      trailing: PlayerUserPointsButton(player: player),
    );
  }
}
