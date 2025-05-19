import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/transfers_embodied_players_offer.dart';

class TransfersEmbodiedPlayersOfferColumn extends StatelessWidget {
  final Player player;
  final TransfersEmbodiedPlayersOffer offer;

  const TransfersEmbodiedPlayersOfferColumn({
    Key? key,
    required this.player,
    required this.offer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isHandled = offer.isAccepted != null;
    return Column(
      children: [
        /// Weekly expenses offered
        ListTile(
          leading: Icon(
            iconMoney,
            color: Colors.green,
            size: iconSizeMedium,
          ),
          title: Text(
              persoFormatCurrency(
                offer.expensesOffered,
              ),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isHandled ? Colors.blueGrey : Colors.green)),
          subtitle: Text('Weekly expenses offered', style: styleItalicBlueGrey),
          shape: shapePersoRoundedBorder(),
        ),

        /// Creation date
        ListTile(
          leading: Icon(
            iconCalendar,
            color: Colors.green,
            size: iconSizeMedium,
          ),
          title: Text(DateFormat(persoDateFormat).format(offer.createdAt),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isHandled ? Colors.blueGrey : Colors.green)),
          subtitle: Text('Creation date', style: styleItalicBlueGrey),
          shape: shapePersoRoundedBorder(),
        ),

        if (isHandled == false)
          ListTile(
            leading: Icon(
              iconCalendar,
              color: Colors.green,
              size: iconSizeMedium,
            ),
            title: Text(
                offer.dateLimit != null
                    ? DateFormat(persoDateFormat).format(offer.dateLimit!)
                    : 'No date limit',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isHandled ? Colors.blueGrey : Colors.green)),
            subtitle:
                Text('Date limit of the offer', style: styleItalicBlueGrey),
            shape: shapePersoRoundedBorder(),
          ),

        /// Number of seasons
        ListTile(
          leading: Icon(
            iconCalendar,
            color: Colors.green,
            size: iconSizeMedium,
          ),
          title: Text(offer.numberSeason.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isHandled ? Colors.blueGrey : Colors.green)),
          subtitle: Text('Number of seasons', style: styleItalicBlueGrey),
          shape: shapePersoRoundedBorder(),
        ),

        /// Comment
        ListTile(
          leading: Icon(
            Icons.comment,
            size: iconSizeMedium,
            color: Colors.green,
          ),
          title: Text(offer.commentForPlayer.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isHandled ? Colors.blueGrey : Colors.green)),
          subtitle: Text('Comment', style: styleItalicBlueGrey),
          shape: shapePersoRoundedBorder(),
        ),

        /// If the offer has been handled
        if (isHandled != false)

          // If the offer was accepted
          offer.isAccepted!
              ? ListTile(
                  leading: Icon(
                    iconSuccessfulOperation,
                    color: Colors.green,
                    size: iconSizeMedium,
                  ),
                  title: Text('Offer accepted',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHandled ? Colors.blueGrey : Colors.green)),
                  subtitle: Row(
                    children: [
                      Icon(
                        iconCalendar,
                        color: Colors.blueGrey,
                        size: iconSizeMedium,
                      ),
                      Text(
                          offer.dateHandled != null
                              ? DateFormat(persoDateFormat)
                                  .format(offer.dateHandled!)
                              : 'Unknown date',
                          style: styleItalicBlueGrey),
                    ],
                  ),
                  shape: shapePersoRoundedBorder(),
                )

              // If the offer was refused
              : ListTile(
                  leading: Icon(
                    iconCancel,
                    color: Colors.red,
                    size: iconSizeMedium,
                  ),
                  title: Text('Offer refused',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHandled ? Colors.blueGrey : Colors.green)),
                  subtitle: Row(
                    children: [
                      Icon(
                        iconCalendar,
                        color: Colors.blueGrey,
                        size: iconSizeMedium,
                      ),
                      Text(
                          offer.dateHandled != null
                              ? DateFormat(persoDateFormat)
                                  .format(offer.dateHandled!)
                              : 'Unknown date',
                          style: styleItalicBlueGrey),
                    ],
                  ),
                  shape: shapePersoRoundedBorder(),
                ),
      ],
    );
  }
}
