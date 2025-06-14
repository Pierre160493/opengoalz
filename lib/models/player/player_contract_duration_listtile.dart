import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/AgeAndBirth.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/player_embodied_offers_page.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';
import 'package:opengoalz/widgets/tickingTime.dart';

class PlayerCardContractDurationListTile extends StatelessWidget {
  final Player player;

  const PlayerCardContractDurationListTile({Key? key, required this.player})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// If the player is not an embodied player
    if (player.dateEndContract == null) {
      return ListTile(
        shape: shapePersoRoundedBorder(),
        leading: Icon(
          iconContract,
          size: iconSizeMedium,
          color: Colors.red,
        ),
        title: Text(
          'Player does not have a contract end date',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Icon(
        iconContract,
        size: iconSizeMedium,
        color: Colors.green,
      ),
      title: Row(
        children: [
          Text(
            'Contract: ',
          ),
          Text(
            calculateAge(
              DateTime.now(),
              player.multiverseSpeed,
              dateEnd: player.dateEndContract,
            ).toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(' seasons left'),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'End date: ${player.dateEndContract != null ? formatDate(player.dateEndContract!) : 'N/A'}',
            style: styleItalicBlueGrey,
          ),
          tickingTimeWidget(player.dateEndContract!)
        ],
      ),
      trailing: player.isEmbodiedByCurrentUser
          ? IconButton(
              tooltip: 'Embodied player contract',
              icon: Icon(
                Icons.pending_actions_outlined,
                size: iconSizeMedium,
                color:
                    player.isEmbodiedByCurrentUser ? colorIsMine : Colors.green,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => persoAlertDialogWithConstrainedContent(
                    title: Text('Manage ${player.getFullName()}\'s contract'),
                    content: Column(
                      children: [
                        /// Contract end date
                        ListTile(
                          leading: Icon(
                            iconContract,
                            size: iconSizeMedium,
                            color: Colors.green,
                          ),
                          title: Text(
                            '${player.dateEndContract != null ? formatDate(player.dateEndContract!) : 'N/A'}',
                          ),
                          subtitle: Text('Contract end date',
                              style: styleItalicBlueGrey),
                          shape: shapePersoRoundedBorder(),
                        ),

                        /// Time left
                        ListTile(
                          leading: Icon(
                            iconContract,
                            size: iconSizeMedium,
                            color: Colors.green,
                          ),
                          title: tickingTimeWidget(player.dateEndContract!),
                          subtitle: Text('Time left before contract expires',
                              style: styleItalicBlueGrey),
                          shape: shapePersoRoundedBorder(),
                        ),

                        /// Number of seasons left
                        ListTile(
                          leading: Icon(
                            iconContract,
                            size: iconSizeMedium,
                            color: Colors.green,
                          ),
                          title: Text(
                            '${calculateAge(DateTime.now(), player.multiverseSpeed, dateEnd: player.dateEndContract!).toStringAsFixed(1)} seasons left',
                          ),
                          subtitle: Text('Number of seasons left',
                              style: styleItalicBlueGrey),
                          shape: shapePersoRoundedBorder(),
                        ),
                      ],
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          /// Close button
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: persoCancelRow(),
                          ),

                          /// End contract button for embodied players
                          if (player.isEmbodiedByCurrentUser)
                            TextButton(
                              onPressed: () async {
                                await operationInDB(
                                  context,
                                  'UPDATE',
                                  'players',
                                  data: {
                                    'date_end_contract':
                                        DateTime.now().toUtc().toIso8601String()
                                  },
                                  matchCriteria: {'id': player.id},
                                  messageSuccess:
                                      'The paperwork is in progress, you\'ll soon be a free agent to pursue your career elsewhere !',
                                );

                                Navigator.of(context).pop();
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.exit_to_app,
                                    size: iconSizeSmall,
                                    color: Colors.red,
                                  ),
                                  formSpacer3,
                                  Text('End contract'),
                                ],
                              ),
                            ),

                          // /// Club renewal button for embodied players
                          // if (player.isPartOfClubOfCurrentUser)
                          //   TextButton(
                          //     onPressed: () async {
                          //       await operationInDB(
                          //         context,
                          //         'UPDATE',
                          //         'players',
                          //         data: {
                          //           'date_end_contract':
                          //               player.dateEndContract!.add(
                          //             Duration(
                          //               days: 7 * 14 * 365,
                          //             ),
                          //           )
                          //         },
                          //         matchCriteria: {'id': player.id},
                          //         messageSuccess:
                          //             'The paperwork is in progress, you\'ll soon be a free agent to pursue your career elsewhere !',
                          //       );

                          //       Navigator.of(context).pop();
                          //     },
                          //     child: Row(
                          //       children: [
                          //         Icon(
                          //           Icons.event_repeat,
                          //           size: iconSizeSmall,
                          //           color: Colors.green,
                          //         ),
                          //         formSpacer3,
                          //         Text('Renew contract'),
                          //       ],
                          //     ),
                          //   ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              iconSize: iconSizeMedium,
              color: Colors.green,
            )
          : null,
    );
  }
}
