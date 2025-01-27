import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/playerPoaching/playerPoachingDialogBox.dart';
import 'package:opengoalz/models/profile.dart';

Widget playerSetAsPoachingIconButton(
    BuildContext context, Player player, Profile user) {
  return player.poaching != null

      /// If the player is already poached, show the icon in orange
      ? IconButton(
          tooltip: 'Modify the poaching status',
          icon: Icon(iconPoaching, color: Colors.orange),
          iconSize: iconSizeSmall,
          onPressed: () async {
            await showPoachingDialog(context, player, user,
                'Modify the poaching of ${player.getFullName()}', 'UPDATE');
          },
        )

      /// If the player is not poached, show the icon
      : IconButton(
          tooltip: 'Try to poach this player',
          icon: Icon(iconPoaching, color: Colors.blueGrey),
          iconSize: iconSizeSmall,
          onPressed: () async {
            await showPoachingDialog(
                context,
                player,
                user,
                'Set ${player.getFullName()} in the list of poached players',
                'INSERT');
          },
        );
}
