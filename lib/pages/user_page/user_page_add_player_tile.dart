import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/widgets/creationDialogBox_Player.dart';
import 'package:opengoalz/extensionBuildContext.dart';

class UserPageAddPlayerTile extends StatelessWidget {
  final Profile user;

  const UserPageAddPlayerTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int playerCount = user.playersIncarnated.length;
    final bool canCreatePlayer =
        user.creditsAvailable >= creditsRequiredForPlayer;
    final Color playerColor = canCreatePlayer ? Colors.green : Colors.orange;

    return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Icon(
        iconPlayers,
        color: Colors.green,
        size: iconSizeMedium,
      ),
      title: Row(
        children: [
          Text('Number of Players: '),
          Text(playerCount.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
      subtitle: Text(
          canCreatePlayer
              ? 'You can handle another player for ${creditsRequiredForPlayer} credits !'
              : 'Missing ${creditsRequiredForPlayer - user.creditsAvailable} credits to handle another player',
          style: styleItalicBlueGrey),
      trailing: IconButton(
        icon: Icon(Icons.person_add_alt_1,
            size: iconSizeMedium, color: playerColor),
        tooltip: 'Add Player',
        onPressed: () {
          if (canCreatePlayer) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CreationDialogBox_Player();
              },
            );
          } else {
            context.showSnackBarError(
              'You cannot create an additional player, missing ${creditsRequiredForPlayer - user.creditsAvailable} credits',
              icon: Icon(
                Icons.warning,
                color: playerColor,
                size: iconSizeMedium,
              ),
            );
          }
        },
      ),
    );
  }
}
