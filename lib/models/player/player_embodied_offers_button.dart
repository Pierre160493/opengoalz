import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerEmbodiedOfferDialogBox.dart';
import 'package:opengoalz/models/player/player_embodied_offers_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

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
        /// If the player is embodied by the current user, navigate to the offers page
        if (player.isEmbodiedByCurrentUser) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  PlayerEmbodiedOffersPage(playerId: player.id),
            ),
          );

          /// If the player's multiverse ID does not match the user's club multiverse ID,
        } else if (player.idMultiverse !=
            Provider.of<UserSessionProvider>(context, listen: false)
                .user
                .selectedClub!
                .idMultiverse) {
          context.showSnackBarError(
            '${player.getFullName()} is not part of your club\'s multiverse ${Provider.of<UserSessionProvider>(context, listen: false).user.selectedClub!.name}.',
          );

          /// Otherwise, show the dialog box for embodied offers
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
