import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
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
            'Time left: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          tickingTimeWidget(player.dateEndContract!)
        ],
      ),
      subtitle: Text(
        'Contract end date: ${player.dateEndContract != null ? formatDate(player.dateEndContract!) : 'N/A'}',
        style: styleItalicBlueGrey,
      ),
      trailing: player.isEmbodiedByCurrentUser
          ? IconButton(
              tooltip: 'Embodied player offers',
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
                        ListTile(
                          leading: Icon(
                            iconContract,
                            size: iconSizeMedium,
                            color: Colors.green,
                          ),
                          title: Text('Contract end date'),
                          subtitle: Text(
                            'Date: ${player.dateEndContract != null ? formatDate(player.dateEndContract!) : 'N/A'}',
                            style: styleItalicBlueGrey,
                          ),
                          shape: shapePersoRoundedBorder(),
                        ),
                        ListTile(
                          leading: Icon(
                            iconContract,
                            size: iconSizeMedium,
                            color: Colors.green,
                          ),
                          title: Text('Time left'),
                          subtitle: tickingTimeWidget(player.dateEndContract!),
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
                            child: persoCancelRow,
                          ),

                          /// End contract button
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
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                formSpacer3,
                                Text('End contract'),
                              ],
                            ),
                          ),
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
