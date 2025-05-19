import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/player/playerEmbodiedOfferDialogBox.dart';
import 'package:opengoalz/models/player/transfers_embodied_players_offer.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';

class PlayerEmbodiedOffersPage extends StatefulWidget {
  final int playerId;

  const PlayerEmbodiedOffersPage({Key? key, required this.playerId})
      : super(key: key);

  @override
  State<PlayerEmbodiedOffersPage> createState() =>
      _PlayerEmbodiedOffersPageState();
}

class _PlayerEmbodiedOffersPageState extends State<PlayerEmbodiedOffersPage> {
  late Stream<Player> _playerStream;

  @override
  void initState() {
    super.initState();
    _playerStream = Supabase.instance.client
        .from('players')
        .stream(primaryKey: ['id'])
        .eq('id', widget.playerId)
        .map((maps) => maps
            .map((map) => Player.fromMap(
                  map,
                  Provider.of<UserSessionProvider>(context, listen: false).user,
                ))
            .first)
        .switchMap((Player player) {
          return Supabase.instance.client
              .from('transfers_embodied_players_offers')
              .stream(primaryKey: ['id'])
              .eq('id_player', player.id)
              .order('created_at', ascending: true)
              .map((maps) => maps
                  .map((map) => TransfersEmbodiedPlayersOffer.fromMap(map))
                  .toList())
              .map((List<TransfersEmbodiedPlayersOffer> offers) {
                player.offersForEmbodied = offers;
                return player;
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Player>(
      stream: _playerStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingCircularAndText('Loading offers...');
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Offers for this player')),
            body: Center(child: Text('ERROR: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('Offers for this player')),
            body: Center(child: Text('No player data available')),
          );
        }

        final Player player = snapshot.data!;
        final List<TransfersEmbodiedPlayersOffer> offers =
            player.offersForEmbodied;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text('Offers made for '),
                player.getPlayerNameClickable(context),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Place an offer from your currently selected club',
                icon: Icon(
                  iconTransfers,
                  size: iconSizeMedium,
                  color: Colors.green,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PlayerEmbodiedOfferDialogBox(idPlayer: player.id);
                    },
                  );
                },
                iconSize: iconSizeMedium,
                color: Colors.green,
              ),
            ],
          ),
          body: MaxWidthContainer(
            child: ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return ListTile(
                  leading: Icon(Icons.account_balance_wallet,
                      color: Colors.green, size: iconSizeMedium),
                  title: Row(
                    children: [
                      getClubNameClickable(context, null, offer.idClub),
                      Text(
                        ' offers weekly expenses of ',
                      ),
                      Text(
                        offer.expensesOffered.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'Comment: ',
                      ),
                      Text(
                        offer.commentForPlayer ?? 'None',
                        style: styleItalicBlueGrey,
                      ),
                    ],
                  ),
                  shape: shapePersoRoundedBorder(),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.open_in_new,
                      size: iconSizeMedium,
                      color: Colors.green,
                    ),
                    tooltip: 'View offer details',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                getClubNameClickable(
                                    context, null, offer.idClub),
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
                                          color: Colors.green)),
                                  subtitle: Text('Weekly expenses offered',
                                      style: styleItalicBlueGrey),
                                  shape: shapePersoRoundedBorder(),
                                ),
                                ListTile(
                                  title: Text(
                                      DateFormat(persoDateFormat)
                                          .format(offer.createdAt),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  subtitle: Text('Creation date',
                                      style: styleItalicBlueGrey),
                                  shape: shapePersoRoundedBorder(),
                                ),
                                ListTile(
                                  title: Text(
                                      offer.dateLimit != null
                                          ? DateFormat(persoDateFormat)
                                              .format(offer.dateLimit!)
                                          : 'No date limit',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  subtitle: Text('Date limit of the offer',
                                      style: styleItalicBlueGrey),
                                  shape: shapePersoRoundedBorder(),
                                ),
                                ListTile(
                                  title: Text(offer.numberSeason.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  subtitle: Text('Number of seasons',
                                      style: styleItalicBlueGrey),
                                  shape: shapePersoRoundedBorder(),
                                ),
                                ListTile(
                                  title: Text(offer.commentForPlayer.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  subtitle: Text('Comment',
                                      style: styleItalicBlueGrey),
                                  shape: shapePersoRoundedBorder(),
                                ),
                              ],
                            ),
                            actions: [
                              /// Cancel button
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.share_arrival_time,
                                            color: Colors.green),
                                        Text(' Decide Later'),
                                      ],
                                    ),
                                  ),

                                  /// Refuse offer button
                                  TextButton(
                                    onPressed: () async {
                                      bool isOK = await operationInDB(
                                          context,
                                          'UPDATE',
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

                                  /// Accept offer button
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
                                          Icon(Icons.check,
                                              color: Colors.green),
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
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
