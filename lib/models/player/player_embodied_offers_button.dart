import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerEmbodiedOfferDialogBox.dart';
import 'package:opengoalz/models/player/player_embodied_offers_page.dart';

class PlayerEmbodiedOffersButton extends StatelessWidget {
  final Player player;

  const PlayerEmbodiedOffersButton({Key? key, required this.player})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Embodied player offers',
      icon: Icon(
        Icons.description,
        // size: iconSizeMedium,
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
    );
  }
}
