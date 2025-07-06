import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/AgeAndBirth.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/dialogs/player_notes_dialog_box.dart';
import 'package:opengoalz/models/player/dialogs/player_shirt_number_dialog_box.dart';
import 'package:opengoalz/models/player/pages/player_history_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

Widget playerShirtNumberIcon(BuildContext context, Player player) {
  bool isPlayerClubSelected =
      Provider.of<UserSessionProvider>(context, listen: false)
              .user
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
            player.notesSmall.toString(),
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

Widget getAgeListTile(BuildContext context, Player player) {
  return Tooltip(
    message: 'Click to see player history',
    waitDuration: const Duration(milliseconds: 500),
    child: ListTile(
      shape: shapePersoRoundedBorder(),
      leading: player.dateDeath != null
          ? Icon(
              iconDead,
              size: iconSizeLarge,
              color: Colors.red,
            )
          : Icon(Icons.cake_outlined, size: iconSizeLarge, color: Colors.green),
      title: Row(
        children: [
          getAgeStringRow(player.age),
        ],
      ),
      subtitle: Row(
        children: [
          Icon(Icons.event, size: iconSizeSmall, color: Colors.green),
          formSpacer3,
          Text(DateFormat(persoDateFormat).format(player.dateBirth),
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.blueGrey)),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerHistoryPage(player: player),
          ),
        );
      },
    ),
  );
}
