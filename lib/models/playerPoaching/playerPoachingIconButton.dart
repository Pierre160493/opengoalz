import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/postgresql_requests.dart';

Widget playerSetAsPoachingIconButton(
    BuildContext context, Player player, Profile user) {
  return player.poaching != null

      /// If the player is already poached, show the icon in orange
      ? IconButton(
          tooltip: 'Modify the poaching status',
          icon: Icon(iconPoaching, color: Colors.orange),
          iconSize: iconSizeSmall,
          onPressed: () async {
            await _showPoachingDialog(context, player, user,
                'Modify the poaching of ${player.getFullName()}', 'UPDATE');
          },
        )

      /// If the player is not poached, show the icon
      : IconButton(
          tooltip: 'Try to poach this player',
          icon: Icon(iconPoaching, color: Colors.blueGrey),
          iconSize: iconSizeSmall,
          onPressed: () async {
            await _showPoachingDialog(
                context,
                player,
                user,
                'Set ${player.getFullName()} in the list of poached players',
                'INSERT');
          },
        );
}

Future<void> _showPoachingDialog(BuildContext context, Player player,
    Profile user, String title, String operation) async {
  String? _notes = player.poaching?.notes;
  int _investmentTarget = player.poaching?.investmentTarget ?? 50;
  int? _maxPrice = player.poaching?.maxPrice;

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(iconPoaching, color: Colors.green, size: iconSizeMedium),
                Text(title),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Scouting network investment
                ListTile(
                    leading: Icon(iconMoney, color: Colors.green),
                    title: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Weekly scouting network investment (>= 0)',
                      ),
                      controller: TextEditingController(
                          text: _investmentTarget.toString()),
                      onChanged: (value) {
                        int? parsedValue = int.tryParse(value);
                        setState(() {
                          _investmentTarget =
                              (parsedValue != null && parsedValue > 0)
                                  ? parsedValue
                                  : 100;
                        });
                      },
                    ),
                    subtitle: Text(
                        'Weekly investment from the scouting network',
                        style: styleItalicBlueGrey),
                    shape: shapePersoRoundedBorder()),

                /// Notes
                ListTile(
                    leading: Icon(iconNotesBig,
                        color: _notes == null || _notes!.isEmpty
                            ? Colors.orange
                            : Colors.green),
                    title: TextField(
                      keyboardType: TextInputType.text,
                      controller: TextEditingController(text: _notes),
                      decoration: InputDecoration(
                        hintText: 'Notes (optional)',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _notes = value;
                        });
                      },
                    ),
                    subtitle: Text('Notes about the player (optional)',
                        style: styleItalicBlueGrey),
                    shape: shapePersoRoundedBorder()),

                /// Max price
                ListTile(
                    leading: Icon(iconTransfers,
                        color:
                            _maxPrice == null ? Colors.orange : Colors.green),
                    title: TextField(
                      keyboardType: TextInputType.number,
                      controller:
                          TextEditingController(text: _maxPrice.toString()),
                      decoration: InputDecoration(
                        hintText:
                            'Max price to bid for the player when he enters auction (optional)',
                      ),
                      onChanged: (value) {
                        int? parsedValue = int.tryParse(value);
                        setState(() {
                          _maxPrice = parsedValue;
                        });
                      },
                    ),
                    subtitle: Text(
                        'Max price to bid for the player when he enters auction (optional)',
                        style: styleItalicBlueGrey),
                    shape: shapePersoRoundedBorder()),
              ],
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  /// Cancel button
                  TextButton(
                    child: persoCancelRow,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),

                  /// Delete button
                  if (operation == 'UPDATE')
                    TextButton(
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          formSpacer3,
                          Text('Stop poaching'),
                        ],
                      ),
                      onPressed: () async {
                        /// The player is no longer poached
                        bool isOk = await operationInDB(
                            context, 'UPDATE', 'players_poaching',
                            matchCriteria: {
                              'id': player.poaching!.id,
                            },
                            data: {
                              'investment_target': 0,
                              'notes': _notes,
                              'max_price': null,
                            });
                        if (isOk)
                          context.showSnackBar(
                              'The scouting network will soon stop working on ${player.getFullName()} and no more investment will be made');
                        Navigator.of(context).pop();
                      },
                    ),

                  /// Confirm button
                  TextButton(
                    child: Row(
                      children: [
                        Icon(
                          iconSuccessfulOperation,
                          color: Colors.green,
                        ),
                        formSpacer3,
                        Text('Confirm'),
                      ],
                    ),
                    onPressed: () async {
                      if (operation == 'UPDATE') {
                        /// If it's an UPDATE
                        await operationInDB(
                            context, 'UPDATE', 'players_poaching',
                            matchCriteria: {
                              'id': player.poaching!.id,
                            },
                            data: {
                              'investment_target': _investmentTarget,
                              'notes': _notes,
                              'max_price': _maxPrice,
                            });
                      } else {
                        /// If it's an INSERT
                        await operationInDB(
                            context, 'INSERT', 'players_poaching',
                            data: {
                              'id_club': user.selectedClub!.id,
                              'id_player': player.id,
                              'investment_target': _investmentTarget,
                              if (_notes != null) 'notes': _notes,
                              if (_maxPrice != null) 'max_price': _maxPrice,
                            });
                      }

                      Navigator.of(context).pop();
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
}
