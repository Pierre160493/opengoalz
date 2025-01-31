import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/playerPoaching/playerPoachingDialogBox.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/scouts_page/scouts_page.dart';

Widget playerSetAsPoachingIconButton(
    BuildContext context, Player player, Profile user) {
  return player.isSelectedClubPoachedPlayer

      /// If the player is already poached, show the icon in orange
      ? IconButton(
          tooltip: 'Open poaching page',
          icon: Icon(iconPoaching, color: Colors.orange),
          iconSize: iconSizeSmall,
          onPressed: () {
            /// Open the scouts page in favorite tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ScoutsPage(initialTab: ScoutsPageTab.poachedPlayers),
              ),
            );
          },
        )

      /// If the player is not poached, show the icon
      : IconButton(
          tooltip: 'Start poaching this player',
          icon: Icon(iconPoaching, color: Colors.blueGrey),
          iconSize: iconSizeSmall,
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PoachingDialog(
                  playerPoached: null,
                  player: player,
                  user: user,
                  title:
                      'Set ${player.getFullName()} in the list of poached players',
                  operation: 'INSERT',
                ),
              ),
            );
          },
        );
}
