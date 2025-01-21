import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/postgresql_requests.dart';

Widget playerPoachingIconButton(
    BuildContext context, Player player, Profile user) {
  /// Promised expenses for the player
  int? promisedExpenses;

  /// Promised price for the player
  int? promisedPrice;

  return IconButton(
    tooltip: 'Try to poach this player',
    icon: Icon(
      iconPoaching,
      // color: player.isPoached! ? Colors.red : Colors.blueGrey,
    ),
    iconSize: iconSizeSmall,
    onPressed: () async {
      if (player.idClub != null && player.idClub != user.selectedClub!.id) {
        /// Show dialog box asking if the user wants to set a promised expenses
        promisedExpenses = await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            int? promisedExpenses;
            return AlertDialog(
              title: Text('Set Promised Expenses'),
              content: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter promised expenses',
                ),
                onChanged: (value) {
                  promisedExpenses = int.tryParse(value);
                },
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop(promisedExpenses);
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
        await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            int? promisedExpenses;
            return AlertDialog(
              title: Text('Set Promised Expenses'),
              content: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter promised expenses',
                ),
                onChanged: (value) {
                  promisedExpenses = int.tryParse(value);
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(promisedExpenses);
                  },
                ),
              ],
            );
          },
        );
      }
      bool isOK =
          await operationInDB(context, 'INSERT', 'players_poaching', data: {
        'id_club': user.selectedClub!.id,
        'id_player': player.id,
        'promised_expenses': promisedExpenses,
        'promised_price': promisedPrice,
      });
      if (isOK) {
        context.showSnackBar(
            'Successfully set ${player.getFullName()} in the list of players you are trying to poach',
            icon: Icon(iconSuccessfulOperation, color: Colors.green));
      }
    },
  );
}
