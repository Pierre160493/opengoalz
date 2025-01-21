import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/postgresql_requests.dart';

Widget playerSetAsFavoriteIconButton(
    BuildContext context, Player player, Profile user) {
  String? notes = null;
  DateTime? dateDelete = null;

  return player.favorite != null

      /// If the player is already a favorite, show the icon in red
      ? IconButton(
          tooltip: 'Remove from favorite players',
          icon: Icon(iconFavorite, color: Colors.red),
          iconSize: iconSizeSmall,
          onPressed: () async {
            bool isOK = await operationInDB(
                context, 'DELETE', 'players_favorite',
                matchCriteria: {
                  'id': player.favorite!.id,
                });
            if (isOK) {
              context.showSnackBar(
                  'Successfully removed ${player.getFullName()} from the list of favorite players',
                  icon: Icon(iconSuccessfulOperation, color: Colors.green));
            }
          },
        )

      /// If the player is not a favorite, show the icon in blue
      : IconButton(
          tooltip: 'Set as favorite',
          icon: Icon(iconFavorite, color: Colors.blueGrey),
          iconSize: iconSizeSmall,
          onPressed: () async {
            /// Show dialog box asking if the user wants to add a note and a date to remove the player from the list of favorite players
            notes = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Text(
                          'Set ${player.getFullName()} in the list of favorite players'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                              leading: Icon(iconNotesBig, color: Colors.green),
                              title: TextField(
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Enter notes on the player',
                                ),
                                onChanged: (value) {
                                  notes = value;
                                },
                              ),
                              subtitle: Text(
                                  'Notes on the favorite player (optional)',
                                  style: styleItalicBlueGrey),
                              shape: shapePersoRoundedBorder()),
                          ListTile(
                            leading: Icon(Icons.auto_delete, color: Colors.red),
                            title: TextButton(
                              child: Text(dateDelete != null
                                  ? formatDate(dateDelete!.toLocal())
                                  : 'Pick a date to automatically remove the player (optional)'),
                              onPressed: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null) {
                                  setState(() {
                                    dateDelete = picked;
                                  });
                                }
                              },
                            ),
                            subtitle: Text(
                                'Date to remove the player from the list of favorite players (optional)',
                                style: styleItalicBlueGrey),
                            shape: shapePersoRoundedBorder(),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: persoCancelRow,
                              onPressed: () {
                                Navigator.of(context).pop();
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
                                      'Set ${player.getFullName()} as favorite'),
                                ],
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(notes);
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

            if (notes != null || dateDelete != null) {
              bool isOK = await operationInDB(
                  context, 'INSERT', 'players_favorite',
                  data: {
                    'id_club': user.selectedClub!.id,
                    'id_player': player.id,
                    if (notes != null) 'notes': notes,
                    if (dateDelete != null)
                      'date_delete': dateDelete!.toIso8601String(),
                  });
              if (isOK) {
                context.showSnackBar(
                    'Successfully set ${player.getFullName()} in the list of favorite players',
                    icon: Icon(iconSuccessfulOperation, color: Colors.green));
              }
            }
          },
        );
}
