import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/transfers_embodied_players_offer.dart';
import 'package:opengoalz/postgresql_requests.dart';

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
            color: isHandled ? Colors.grey : Colors.green,
          ),
        ),
      ],
    ),
    subtitle: Row(
      children: [
        Text('Comment: '),
        Text(
          offer.commentForPlayer ?? 'None',
          style: styleItalicBlueGrey,
        ),
      ],
    ),
    shape: shapePersoRoundedBorder(),
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                getClubNameClickable(context, null, offer.idClub),
                Text(' Offer'),
              ],
            ),
            content: Column(
              children: [
                ListTile(
                  title: Text(
                      persoFormatCurrency(
                        offer.expensesOffered,
                      ),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHandled ? Colors.grey : Colors.green)),
                  subtitle: Text('Weekly expenses offered',
                      style: styleItalicBlueGrey),
                  shape: shapePersoRoundedBorder(),
                ),
                ListTile(
                  title: Text(
                      DateFormat(persoDateFormat).format(offer.createdAt),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHandled ? Colors.grey : Colors.green)),
                  subtitle: Text('Creation date', style: styleItalicBlueGrey),
                  shape: shapePersoRoundedBorder(),
                ),
                ListTile(
                  title: Text(
                      offer.dateLimit != null
                          ? DateFormat(persoDateFormat).format(offer.dateLimit!)
                          : 'No date limit',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHandled ? Colors.grey : Colors.green)),
                  subtitle: Text('Date limit of the offer',
                      style: styleItalicBlueGrey),
                  shape: shapePersoRoundedBorder(),
                ),
                ListTile(
                  title: Text(offer.numberSeason.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHandled ? Colors.grey : Colors.green)),
                  subtitle:
                      Text('Number of seasons', style: styleItalicBlueGrey),
                  shape: shapePersoRoundedBorder(),
                ),
                ListTile(
                  title: Text(offer.commentForPlayer.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHandled ? Colors.grey : Colors.green)),
                  subtitle: Text('Comment', style: styleItalicBlueGrey),
                  shape: shapePersoRoundedBorder(),
                ),
                if (isHandled && offer.dateDelete != null)
                  ListTile(
                    title: Text(
                      DateFormat(persoDateFormat).format(offer.dateDelete!),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    subtitle: Text('Handled at', style: styleItalicBlueGrey),
                    shape: shapePersoRoundedBorder(),
                  ),
              ],
            ),
            actions: [
              if (!isHandled)
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.share_arrival_time, color: Colors.green),
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
                          Icon(Icons.cancel, color: Colors.red),
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
                            Icon(Icons.check, color: Colors.green),
                            Text('Accept'),
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
