import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerNotesDialogBox.dart';
import 'package:opengoalz/models/player/playerShirtNumberDialogBox.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

Widget playerShirtNumberIcon(BuildContext context, Player player) {
  bool isPlayerClubSelected =
      Provider.of<SessionProvider>(context, listen: false)
              .user!
              .selectedClub!
              .id ==
          player.idClub;
  return InkWell(
    onTap: () {
      if (isPlayerClubSelected)
        // Open the shirt number dialog box
        showDialog(
          context: context,
          builder: (context) {
            return PlayerShirtNumberDialogBox(player: player);
          },
        );
    },
    child: Tooltip(
      message:
          'Shirt number: ${player.shirtNumber == null ? 'None' : player.shirtNumber}',
      child: Row(
        children: [
          Icon(
            iconShirt,
            color: player.shirtNumber == null ? Colors.red : Colors.green,
          ),
          if (player.shirtNumber != null)
            Text(
              player.shirtNumber.toString(),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    ),
  );
}

Widget playerSmallNotesIcon(BuildContext context, Player player) {
  return InkWell(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) {
          return PlayerNotesDialogBox(player: player);
        },
      );
    },
    child: Tooltip(
      message: 'Notes: ${player.notes}',
      child: Row(
        children: [
          Icon(
            iconNotesSmall,
            color: Colors.green,
          ),
          Text(
            player.notesSmall == null ? '' : player.notesSmall.toString(),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
