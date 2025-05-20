import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerEmbodiedOfferDialogBox.dart';
import 'package:opengoalz/models/player/player_embodied_offers_page.dart';
import 'package:opengoalz/models/profile.dart';

class PlayerCardEmbodiedListTile extends StatelessWidget {
  final Player player;

  const PlayerCardEmbodiedListTile({Key? key, required this.player})
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
        color: Colors.blue,
      ),
      title: Row(
        children: [
          Text(
            'Embodied player',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            'User: ',
            style: styleItalicBlueGrey,
          ),
          getUserNameClickable(context, userName: player.userName),
        ],
      ),
      trailing: IconButton(
        tooltip: 'Embodied player offers',
        icon: Icon(
          iconTransfers,
          size: iconSizeMedium,
          color: player.isEmbodiedByCurrentUser ? colorIsMine : Colors.green,
        ),
        onPressed: () {
          if (player.isEmbodiedByCurrentUser) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    PlayerEmbodiedOffersPage(playerId: player.id),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return PlayerEmbodiedOfferDialogBox(idPlayer: player.id);
              },
            );
          }
        },
        iconSize: iconSizeMedium,
        color: Colors.green,
      ),
    );
  }
}
