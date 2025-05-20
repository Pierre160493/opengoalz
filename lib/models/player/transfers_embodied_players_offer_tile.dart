import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/transfers_embodied_players_offer.dart';
import 'package:opengoalz/models/player/transfers_embodied_players_offer_dialog_column.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';

Widget transfersEmbodiedPlayersOfferTile(BuildContext context, Player player,
    TransfersEmbodiedPlayersOffer offer, bool isHandled) {
  return ListTile(
    leading: Icon(Icons.account_balance_wallet,
        color: isHandled ? Colors.grey : Colors.green, size: iconSizeMedium),
    title: Row(
      children: [
        getClubNameClickable(context, null, offer.idClub),
        Text(' offers weekly expenses of '),
        Text(
          offer.expensesOffered.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    ),
    subtitle: offer.isAccepted == null
        ? Row(
            children: [
              Text('Creation date: '),
              Text(
                DateFormat(persoDateFormat).format(offer.createdAt),
                style: styleItalicBlueGrey,
              ),
            ],
          )
        : offer.isAccepted == true
            ? Row(
                children: [
                  Icon(iconCalendar, color: Colors.green),
                  Text('Accepted on '),
                  Text(
                    offer.dateHandled != null
                        ? DateFormat(persoDateFormat).format(offer.dateHandled!)
                        : 'Unknown date',
                    style: styleItalicBlueGrey,
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(iconCalendar, color: Colors.red),
                  Text('Refused on '),
                  Text(
                    offer.dateHandled != null
                        ? DateFormat(persoDateFormat).format(offer.dateHandled!)
                        : 'Unknown date',
                    style: styleItalicBlueGrey,
                  ),
                ],
              ),

    // Row(
    //   children: [
    //     Text('Comment: '),
    //     Text(
    //       offer.commentForPlayer ?? 'None',
    //       style: styleItalicBlueGrey,
    //     ),
    //   ],
    // ),
    shape: shapePersoRoundedBorder(),
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return persoAlertDialogWithConstrainedContent(
            title: Row(
              children: [
                Text(
                  'Offer from ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                getClubNameClickable(context, null, offer.idClub),
              ],
            ),
            content: TransfersEmbodiedPlayersOfferColumn(
              player: player,
              offer: offer,
            ),
            actions: [
              if (!isHandled)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.share_arrival_time,
                              color: Colors.green, size: iconSizeSmall),
                          Text(' Decide Later'),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        bool isOK = await operationInDB(context, 'UPDATE',
                            'transfers_embodied_players_offers',
                            data: {
                              'is_accepted': false,
                            },
                            matchCriteria: {
                              'id': offer.id
                            });

                        if (isOK) {
                          Navigator.of(context).pop();
                          context.showSnackBarSuccess(
                            'Offer successfully refused',
                          );
                        } else {
                          context.showSnackBarError(
                            'Error refusing the offer, please contact the support',
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.cancel,
                              color: Colors.red, size: iconSizeSmall),
                          Text(' Refuse'),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: player.idClub == null
                          ? ''
                          : 'You have to leave your current club before accepting an offer',
                      child: TextButton(
                        onPressed: player.idClub == null
                            ? () async {
                                bool isOK = await operationInDB(
                                    context,
                                    'UPDATE',
                                    'transfers_embodied_players_offers',
                                    data: {
                                      'is_accepted': true,
                                    },
                                    matchCriteria: {
                                      'id': offer.id
                                    });

                                if (isOK) {
                                  Navigator.of(context).pop();
                                  context.showSnackBarSuccess(
                                    'Offer successfully accepted, the paperwork is in progress !',
                                  );
                                } else {
                                  context.showSnackBarError(
                                    'Error accepting the offer, please contact the support',
                                  );
                                }
                              }
                            : null, // Disabled if player has a club
                        child: Row(
                          children: [
                            Icon(iconSuccessfulOperation,
                                color: Colors.green, size: iconSizeSmall),
                            Text(' Accept'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      );
    },
    trailing: Tooltip(
      message: isHandled
          ? (offer.isAccepted == true ? 'Offer accepted' : 'Offer refused')
          : 'Pending decision',
      child: Icon(
        isHandled
            ? (offer.isAccepted == true ? Icons.check_circle : Icons.cancel)
            : Icons.hourglass_top,
        color: isHandled
            ? (offer.isAccepted == true ? Colors.green : Colors.red)
            : Colors.orange,
        size: iconSizeMedium,
      ),
    ),
  );
}
