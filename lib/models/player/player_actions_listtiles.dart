import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerSellFireDialogBox.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';

class PlayerActionsWidget extends StatelessWidget {
  final Player player;
  final int? index;

  const PlayerActionsWidget({Key? key, required this.player, this.index})
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
                      Navigator.pop(context); // Close dialog
                      await operationInDB(context, 'UPDATE', 'players',
                          data: {
                            'id_user': null,
                          },
                          matchCriteria: {'id': player.id},
                          messageSuccess:
                              player.getFullName() + ' is glad to be free !');
                    },
                    subtitle:
                        Text('Unembody ${player.getFullName()} from your club'),
                    shape: shapePersoRoundedBorder(),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
