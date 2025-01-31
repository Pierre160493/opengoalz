import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/scouts_page/scouts_page.dart';
import 'package:opengoalz/postgresql_requests.dart';

Widget playerSetAsFavoriteIconButton(
    BuildContext context, Player player, Profile user) {
  String? _notes = null;
  DateTime? _dateDelete = null;

  return player.isSelectedClubFavoritePlayer

      /// If the player is already a favorite, show the icon in red
      ? IconButton(
          tooltip: 'Open favorite players page',
          icon: Icon(iconFavorite, color: Colors.red),
          iconSize: iconSizeSmall,
          onPressed: () {
            /// Open the scouts page in favorite tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ScoutsPage(initialTab: ScoutsPageTab.followedPlayers),
              ),
            );
          },
        )

      /// If the player is not a favorite, show the icon in blue
      : IconButton(
          tooltip: 'Set as favorite',
          icon: Icon(iconFavorite, color: Colors.blueGrey),
          iconSize: iconSizeSmall,
          onPressed: () async {
            /// Show dialog box asking if the user wants to add a note and a date to remove the player from the list of favorite players
            bool? shouldContinue = await showDialog<bool>(
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
                                  _notes = value;
                                },
                              ),
                              subtitle: Text(
                                  'Notes on the favorite player (optional)',
                                  style: styleItalicBlueGrey),
                              shape: shapePersoRoundedBorder()),
                          ListTile(
                            leading: Icon(Icons.auto_delete, color: Colors.red),
                            title: TextButton(
                              child: Text(_dateDelete != null
                                  ? formatDate(_dateDelete!.toLocal())
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
                                    _dateDelete = picked;
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
                                      'Set ${player.getFullName()} as favorite'),
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
                  context, 'INSERT', 'players_favorite',
                  data: {
                    'id_club': user.selectedClub!.id,
                    'id_player': player.id,
                    if (_notes != null) 'notes': _notes,
                    if (_dateDelete != null)
                      'date_delete': _dateDelete!.toIso8601String(),
                  });
              if (isOK) {
                context.showSnackBar(
                    'Successfully set ${player.getFullName()} in the list of favorite players',
                    icon: Icon(iconSuccessfulOperation, color: Colors.green));
              }
            } else {
              context.showSnackBar(
                  'Canceled setting ${player.getFullName()} as favorite',
                  icon: Icon(iconCancel, color: Colors.red));
            }
          },
        );
}
