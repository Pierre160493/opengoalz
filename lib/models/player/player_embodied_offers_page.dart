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
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';

class PlayerEmbodiedOffersPage extends StatefulWidget {
  final int playerId;

  const PlayerEmbodiedOffersPage({Key? key, required this.playerId})
      : super(key: key);

  @override
  State<PlayerEmbodiedOffersPage> createState() =>
      _PlayerEmbodiedOffersPageState();
}

class _PlayerEmbodiedOffersPageState extends State<PlayerEmbodiedOffersPage>
    with SingleTickerProviderStateMixin {
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

        final undecidedOffers =
            offers.where((o) => o.isAccepted == null).toList();
        final handledOffers =
            offers.where((o) => o.isAccepted != null).toList();

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text('Offers for '),
                player.getPlayerNameClickable(context),
              ],
            ),
            actions: [
              /// Filter button
              IconButton(
                tooltip: 'Order offers by',
                icon: Icon(
                  Icons.sort,
                  size: iconSizeMedium,
                  color: Colors.green,
                ),
                onPressed: () {},
                iconSize: iconSizeMedium,
              ),

              /// Place an offer from your currently selected club
              IconButton(
                tooltip: 'Place an offer from your club',
                icon: Icon(
                  iconTransfers,
                  size: iconSizeMedium,
                  color: colorIsSelected,
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
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(tabs: [
                    buildTabWithIcon(
                        icon: Icons.hourglass_top,
                        text: 'Pending (${undecidedOffers.length})'),
                    buildTabWithIcon(
                        icon: Icons.check_circle_outline,
                        text: 'Closed (${handledOffers.length})'),
                  ]),
                  Expanded(
                    child: TabBarView(children: [
                      _buildOffersList(context, player, undecidedOffers,
                          isHandled: false),
                      _buildOffersList(context, player, handledOffers,
                          isHandled: true),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOffersList(BuildContext context, Player player,
      List<TransfersEmbodiedPlayersOffer> offers,
      {required bool isHandled}) {
    if (offers.isEmpty) {
      return Center(
        child: Text(
          isHandled
              ? 'No handled offers yet'
              : 'You don\'t have any pending offers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return ListTile(
          leading: Icon(Icons.account_balance_wallet,
              color: isHandled ? Colors.grey : Colors.green,
              size: iconSizeMedium),
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
          trailing: IconButton(
            icon: Icon(
              Icons.open_in_new,
              size: iconSizeMedium,
              color: isHandled ? Colors.grey : Colors.green,
            ),
            tooltip: 'View offer details',
            onPressed: () {
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
                                  color:
                                      isHandled ? Colors.grey : Colors.green)),
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
                                  color:
                                      isHandled ? Colors.grey : Colors.green)),
                          subtitle:
                              Text('Creation date', style: styleItalicBlueGrey),
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
                                  color:
                                      isHandled ? Colors.grey : Colors.green)),
                          subtitle: Text('Date limit of the offer',
                              style: styleItalicBlueGrey),
                          shape: shapePersoRoundedBorder(),
                        ),
                        ListTile(
                          title: Text(offer.numberSeason.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isHandled ? Colors.grey : Colors.green)),
                          subtitle: Text('Number of seasons',
                              style: styleItalicBlueGrey),
                          shape: shapePersoRoundedBorder(),
                        ),
                        ListTile(
                          title: Text(offer.commentForPlayer.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isHandled ? Colors.grey : Colors.green)),
                          subtitle: Text('Comment', style: styleItalicBlueGrey),
                          shape: shapePersoRoundedBorder(),
                        ),
                        if (isHandled && offer.dateDelete != null)
                          ListTile(
                            title: Text(
                              DateFormat(persoDateFormat)
                                  .format(offer.dateDelete!),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            subtitle:
                                Text('Handled at', style: styleItalicBlueGrey),
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
                                  Icon(Icons.share_arrival_time,
                                      color: Colors.green),
                                  Text(' Decide Later'),
                                ],
                              ),
                            ),
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
          ),
        );
      },
    );
  }
}
