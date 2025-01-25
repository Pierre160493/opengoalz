import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/postgresql_requests.dart';

Widget playerSetAsPoachingIconButton(
    BuildContext context, Player player, Profile user) {
  String? _notes;
  int _investmentTarget = 100;

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

      /// If the player is not poached, show the icon
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
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Notes (optional)',
                                ),
                                onChanged: (value) {
                                  _notes = value;
                                },
                              ),
                              subtitle: Text(
                                  'Notes about the player (optional)',
                                  style: styleItalicBlueGrey),
                              shape: shapePersoRoundedBorder()),
                          ListTile(
                              leading: Icon(iconNotesBig, color: Colors.green),
                              title: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText:
                                      'Weekly scouting network investment',
                                ),
                                onChanged: (value) {
                                  int? parsedValue = int.tryParse(value);
                                  _investmentTarget =
                                      (parsedValue != null && parsedValue > 0)
                                          ? parsedValue
                                          : 100;
                                },
                              ),
                              subtitle: Text(
                                  'Weekly investment from the scouting network',
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
                                      'Start poaching ${player.getFullName()}'),
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
                    'investment_target': _investmentTarget,
                    if (_notes != null) 'notes': _notes,
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
