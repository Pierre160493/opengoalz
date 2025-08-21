import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/dialogs/playerSellFireDialogBox.dart';
import 'package:opengoalz/models/player/pages/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';
import 'package:provider/provider.dart';

class PlayerActionsIconButton extends StatelessWidget {
  final Player player;
  final int? index;

  const PlayerActionsIconButton({Key? key, required this.player, this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.pending_actions_outlined, color: Colors.green),
      tooltip: 'Player actions',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => persoAlertDialogWithConstrainedContent(
            title: Text('Actions for ${player.getFullName()}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Open the player page if the page contains multiple players
                if (index != null)
                  ListTile(
                    leading: Icon(Icons.open_in_new,
                        color: Colors.green, size: iconSizeMedium),
                    title: Text('Open Page'),
                    onTap: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayersPage(
                            playerSearchCriterias:
                                PlayerSearchCriterias(idPlayer: [player.id]),
                          ),
                        ),
                      );
                    },
                    subtitle: Text('Open ${player.getFullName()}\'s page'),
                    shape: shapePersoRoundedBorder(),
                  ),

                /// Actions for players belonging to the current user's club
                if (player.isPartOfClubOfCurrentUser) ...[
                  if (player.dateBidEnd == null) ...[
                    /// Sell the player
                    ListTile(
                      leading: Icon(iconTransfers,
                          color: Colors.red, size: iconSizeMedium),
                      title: Text('Sell'),
                      onTap: () {
                        Navigator.pop(context); // Close dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SellFirePlayerDialogBox(idPlayer: player.id);
                          },
                        );
                      },
                      subtitle: Text(
                          'Put ${player.getFullName()} in auction for sale'),
                      shape: shapePersoRoundedBorder(),
                    ),

                    /// Fire the player
                    ListTile(
                      leading: Icon(iconLeaveClub,
                          color: Colors.red, size: iconSizeMedium),
                      title: Text('Fire'),
                      onTap: () {
                        Navigator.pop(context); // Close dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SellFirePlayerDialogBox(
                                idPlayer: player.id, firePlayer: true);
                          },
                        );
                      },
                      subtitle:
                          Text('Fire ${player.getFullName()} from your club'),
                      shape: shapePersoRoundedBorder(),
                    ),
                  ] else ...[
                    /// Unfire the player
                    ListTile(
                      leading: Icon(Icons.cancel,
                          color: Colors.green, size: iconSizeMedium),
                      title: Text('Unfire'),
                      onTap: () async {
                        Navigator.pop(context); // Close dialog
                        await operationInDB(context, 'UPDATE', 'players',
                            data: {
                              'date_bid_end': null,
                            },
                            matchCriteria: {'id': player.id},
                            messageSuccess: player.getFullName() +
                                ' is glad to stay in your club !');
                      },
                      subtitle:
                          Text('Unfire ${player.getFullName()} from your club'),
                      shape: shapePersoRoundedBorder(),
                    ),
                  ]
                ], // End if player.isPartOfClubOfCurrentUser

                /// Actions for players embodied by the current user
                if (player.isEmbodiedByCurrentUser) ...[
                  /// Unembody the player
                  ListTile(
                    leading: Icon(Icons.cancel,
                        color: Colors.red, size: iconSizeMedium),
                    title: Text('Unembody'),
                    onTap: () async {
                      /// Dialog prompting are you sure to unembody the player
                      final confirmation = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                                'Are you sure you want to stop embodying ${player.getFullName()} ?'),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  /// Cancel button
                                  TextButton(
                                    child: persoCancelRow(),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),

                                  /// Confirm button
                                  TextButton(
                                    child: persoValidRow('Confirm'),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmation != true) {
                        return; // User canceled the action
                      }

                      Navigator.pop(context); // Close dialog
                      /// Proceed to unembody the player
                      await operationInDB(
                          context, 'FUNCTION', 'players_handle_embodied_player',
                          data: {
                            'inp_id_player': player.id,
                            'inp_username': Provider.of<UserSessionProvider>(
                                    context,
                                    listen: false)
                                .user
                                .username,
                            'inp_stop_embody': true,
                          },
                          messageSuccess: 'You are no longer embodying ' +
                              player.getFullName());
                    },
                    subtitle: Text('Stop embodying ${player.getFullName()}',
                        style: styleItalicBlueGrey),
                    shape: shapePersoRoundedBorder(),
                  ),

                  /// Retire the player
                  ListTile(
                    leading: Icon(iconRetired,
                        color: Colors.red, size: iconSizeMedium),
                    title: Text('Retire'),
                    onTap: () async {
                      /// Dialog prompting are you sure to unembody the player
                      final confirmation = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                                'Are you sure you want to retire ${player.getFullName()} ?'),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  /// Cancel button
                                  TextButton(
                                    child: persoCancelRow(),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),

                                  /// Confirm button
                                  TextButton(
                                    child: persoValidRow('Confirm'),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmation != true) {
                        return; // User canceled the action
                      }

                      /// Proceed to unembody the player
                      bool isOK = await operationInDB(
                          context, 'FUNCTION', 'players_handle_embodied_player',
                          data: {
                            'inp_id_player': player.id,
                            'inp_username': Provider.of<UserSessionProvider>(
                                    context,
                                    listen: false)
                                .user
                                .username,
                            'inp_retire_embodied': true,
                          },
                          messageSuccess:
                              '${player.getFullName()} is now retired !');
                      if (isOK) Navigator.pop(context);
                    },
                    subtitle: Text('Retire ${player.getFullName()}',
                        style: styleItalicBlueGrey),
                    shape: shapePersoRoundedBorder(),
                  ),
                ],

                if (player.idClub == null && player.userName == null)

                  /// Embody the player
                  ListTile(
                    leading: Icon(iconUser,
                        color: Colors.green, size: iconSizeMedium),
                    title: Text('Embody'),
                    onTap: () async {
                      /// Dialog prompting are you sure to unembody the player
                      final confirmation = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                'Are you sure you want to mbody ${player.getFullName()}'),
                            content: Text(
                                'This will make you the player\'s user and you will be able to control his decisions and actions.'),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  /// Cancel button
                                  TextButton(
                                    child: persoCancelRow(),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),

                                  /// Confirm button
                                  TextButton(
                                    child: persoValidRow('Confirm'),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmation != true) {
                        return; // User canceled the action
                      }

                      Navigator.pop(context); // Close dialog
                      /// Proceed to embody the player
                      await operationInDB(
                          context, 'FUNCTION', 'players_handle_embodied_player',
                          data: {
                            'inp_id_player': player.id,
                            'inp_username': Provider.of<UserSessionProvider>(
                                    context,
                                    listen: false)
                                .user
                                .username,
                            'inp_start_embody': true,
                          },
                          messageSuccess:
                              'You are now embodying ' + player.getFullName());
                    },
                    subtitle: Text('Start embodying ${player.getFullName()}',
                        style: styleItalicBlueGrey),
                    shape: shapePersoRoundedBorder(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
