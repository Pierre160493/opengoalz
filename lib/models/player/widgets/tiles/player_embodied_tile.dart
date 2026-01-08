import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/player_embodied_offers_button.dart';
import 'package:opengoalz/models/profile.dart';

class PlayerEmbodiedTile extends StatelessWidget {
  final Player player;

  const PlayerEmbodiedTile({Key? key, required this.player}) : super(key: key);

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
            style: TextStyle(
              fontSize: fontSizeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            'User: ',
            style: styleItalicBlueGrey.copyWith(fontSize: fontSizeSmall),
          ),
          getUserNameClickable(context, userName: player.userName),
        ],
      ),
      trailing: PlayerEmbodiedOffersButton(
        player: player,
      ),
    );
  }
}
