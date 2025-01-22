import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/postgresql_requests.dart';

Widget playerSetAsPoachingIconButton(
    BuildContext context, Player player, Profile user) {
  int? promisedExpenses;
  int? promisedPrice;

  return player.poaching != null

      /// If the player is already poached, show the icon in red
      ? IconButton(
          tooltip: 'Remove from poached players',
          icon: Icon(iconPoaching, color: Colors.red),
          iconSize: iconSizeSmall,
          onPressed: () async {
            bool isOK = await operationInDB(
                context, 'DELETE', 'players_poaching',
                matchCriteria: {
                  'id': player.poaching!.id,
                });
            if (isOK) {
              context.showSnackBar(
                  'Successfully removed ${player.getFullName()} from the list of poached players',
                  icon: Icon(iconSuccessfulOperation, color: Colors.green));
            }
          },
        )

      /// If the player is not poached, show the icon in blue
      : IconButton(
          tooltip: 'Try to poach this player',
          icon: Icon(iconPoaching, color: Colors.blueGrey),
          iconSize: iconSizeSmall,
          onPressed: () async {
            bool? shouldContinue = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Text(
                          'Set ${player.getFullName()} in the list of poached players'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                              leading: Icon(iconNotesBig, color: Colors.green),
                              title: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Enter promised expenses',
                                ),
                                onChanged: (value) {
                                  promisedExpenses = int.tryParse(value);
                                },
                              ),
                              subtitle: Text(
                                  'Promised expenses for the player (optional)',
                                  style: styleItalicBlueGrey),
                              shape: shapePersoRoundedBorder()),
                          ListTile(
                              leading: Icon(iconNotesBig, color: Colors.green),
                              title: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Enter promised price',
                                ),
                                onChanged: (value) {
                                  promisedPrice = int.tryParse(value);
                                },
                              ),
                              subtitle: Text(
                                  'Promised price for the player (optional)',
                                  style: styleItalicBlueGrey),
                              shape: shapePersoRoundedBorder()),
                        ],
                      ),
                      actions: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: persoCancelRow,
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: Row(
                                children: [
                                  Icon(
                                    iconSuccessfulOperation,
                                    color: Colors.green,
                                  ),
                                  formSpacer3,
                                  Text(
                                      'Set ${player.getFullName()} as poached'),
                                ],
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            );

            if (shouldContinue == true) {
              bool isOK = await operationInDB(
                  context, 'INSERT', 'players_poaching',
                  data: {
                    'id_club': user.selectedClub!.id,
                    'id_player': player.id,
                    if (promisedExpenses != null)
                      'promised_expenses': promisedExpenses,
                    if (promisedPrice != null) 'promised_price': promisedPrice,
                  });
              if (isOK) {
                context.showSnackBar(
                    'Successfully set ${player.getFullName()} in the list of players you are trying to poach',
                    icon: Icon(iconSuccessfulOperation, color: Colors.green));
              }
            } else {
              context.showSnackBar(
                  'Canceled setting ${player.getFullName()} as poached',
                  icon: Icon(iconCancel, color: Colors.red));
            }
          },
        );
}
