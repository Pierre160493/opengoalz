import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/others/clubCashListTile.dart';
import 'package:opengoalz/models/player/dialogs/playerSearchDialogBox.dart';
import 'package:opengoalz/models/player/widgets/cards/player_card_main.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/transfer_bid.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/pages/players_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class TransferPage extends StatefulWidget {
  final int idClub;
  const TransferPage({Key? key, required this.idClub}) : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute<void>(
      builder: (context) => TransferPage(idClub: idClub),
    );
  }

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Stream<List<TransferBid>> _IdPlayersTransferStream;
  late Stream<List<Player>> _playersStream;
  late final Profile currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    currentUser = Provider.of<UserSessionProvider>(context, listen: false).user;

    // Stream to fetch the list of player IDs that the club has shown interest in
    _IdPlayersTransferStream = supabase
        .from('transfers_bids')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.idClub)
        .map((maps) => maps.map((map) => TransferBid.fromMap(map)).toList());

    // Stream to fetch players based on the player IDs from the transfer bids
    _playersStream = _IdPlayersTransferStream.asyncExpand<List<Player>>(
        (List<TransferBid> transferBids) {
      List<int> playerIdsList =
          transferBids.map((bid) => bid.idPlayer).toList();

      return supabase
          .from('players')
          .stream(primaryKey: ['id'])
          .inFilter('id', playerIdsList)
          .order('date_birth', ascending: true)
          .map((maps) =>
              maps.map((map) => Player.fromMap(map, currentUser)).toList())
          .switchMap((List<Player> players) {
            // Fetch the club's players
            return supabase
                .from('players')
                .stream(primaryKey: ['id'])
                .eq(
                    'id_club',
                    widget
                        .idClub) // Fetch the club's players to get their clubs
                .map((maps) => maps
                    .map((map) => Player.fromMap(map, currentUser))
                    .toList())
                .map((List<Player> playersSell) {
                  players.addAll(
                      playersSell.where((player) => player.dateBidEnd != null));
                  return players;
                });
          })
          .switchMap((List<Player> players) {
            // Fetch their clubs if there are any club IDs
            final clubIds = players
                .map((player) => player.idClub)
                .where((idClub) => idClub != null)
                .toSet()
                .cast<Object>()
                .toList();

            if (clubIds.isEmpty) {
              return Stream.value(players);
            }

            return supabase
                .from('clubs')
                .stream(primaryKey: ['id'])
                .inFilter('id', clubIds)
                .map((maps) => maps
                    .map((map) => Club.fromMap(
                        map,
                        Provider.of<UserSessionProvider>(context, listen: false)
                            .user))
                    .toList())
                .map((List<Club> clubs) {
                  for (Player player
                      in players.where((player) => player.idClub != null)) {
                    player.club =
                        clubs.firstWhere((club) => club.id == player.idClub);
                  }
                  return players;
                });
          })
          .switchMap((List<Player> players) {
            // Fetch their transfer bids
            return supabase
                .from('transfers_bids')
                .stream(primaryKey: ['id'])
                .inFilter('id_player',
                    players.map((player) => player.id).toSet().toList())
                .order('created_at', ascending: true)
                .map((maps) =>
                    maps.map((map) => TransferBid.fromMap(map)).toList())
                .map((List<TransferBid> transfersBids) {
                  for (Player player in players) {
                    player.transferBids.clear();
                    player.transferBids.addAll(transfersBids
                        .where((bid) => bid.idPlayer == player.id));
                  }
                  return players;
                });
          });
    }).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Player>>(
        stream: _playersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCircularAndText('Loading transfers...');
          } else if (snapshot.hasError) {
            return Center(
              child: Text('ERROR: ${snapshot.error}'),
            );
          } else {
            final players = snapshot.data ?? [];
            final playersSell = players
                .where((player) => player.idClub == widget.idClub)
                .toList();
            final playersBuy = players
                .where((player) => player.idClub != widget.idClub)
                .toList();
            return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Transfer Page',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: goBackIconButton(context),
                  actions: [
                    IconButton(
                      tooltip: 'Search for players',
                      onPressed: () {
                        showDialog<PlayerSearchCriterias>(
                          context: context,
                          builder: (BuildContext context) {
                            return playerSearchDialogBox(
                              inputPlayerSearchCriterias:
                                  PlayerSearchCriterias(),
                            );
                          },
                        ).then((playerSearchCriterias) {
                          if (playerSearchCriterias != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayersPage(
                                  playerSearchCriterias: playerSearchCriterias,
                                ),
                              ),
                            );
                          }
                        });
                      },
                      icon: Icon(Icons.person_search, color: Colors.green),
                    ),
                  ],
                ),
                drawer: AppDrawer(),
                body: MaxWidthContainer(
                  child: Column(
                    children: [
                      getClubCashListTile(context, currentUser.selectedClub!),
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          buildTabWithIcon(
                              icon: Icons.local_offer,
                              text: 'Sell (${playersSell.length})'),
                          buildTabWithIcon(
                              icon: Icons.shopping_cart,
                              text: 'Buy (${playersBuy.length})'),
                        ],
                      ),
                      Expanded(
                        child:
                            TabBarView(controller: _tabController, children: [
                          _playersTransferWidget(playersSell),
                          _playersTransferWidget(playersBuy),
                        ]),
                      ),
                    ],
                  ),
                ));
            // }
          }
        });
  }

  Widget _playersTransferWidget(List<Player> players) {
    if (players.isEmpty) {
      return const Center(
        child: Text('No active transfers found'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final Player player = players[index];
              return InkWell(
                onTap: () {
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
                child: PlayerCard(
                    player: player,
                    index: players.length == 1 ? 0 : index + 1,
                    isExpanded: players.length == 1 ? true : false),
              );
            },
          ),
        )
      ],
    );
  }
}
