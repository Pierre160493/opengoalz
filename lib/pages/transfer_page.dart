import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/transfer_bid.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/player/class/player.dart';
import 'package:opengoalz/player/players_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
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
  late Stream<List<Player>> _playerStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _IdPlayersTransferStream = supabase
        .from('transfers_bids')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.idClub)
        .map((maps) => maps.map((map) => TransferBid.fromMap(map)).toList());

    _playerStream = _IdPlayersTransferStream.asyncExpand((playerIds) {
      List<int> playerIdsList = playerIds.map((bid) => bid.idPlayer).toList();
      return supabase
          .from('players')
          .stream(primaryKey: ['id'])
          .inFilter('id', playerIdsList)
          .order('date_birth', ascending: true)
          .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
    }).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Player>>(
        stream: _playerStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('ERROR: ${snapshot.error}'),
            );
          } else {
            final List<Player> players = snapshot.data ?? [];
            if (players.isEmpty) {
              return const Center(
                child: Text('ERROR: No players found'),
              );
            } else {
              final List<Player> playersSell = players.where((player) {
                return player.id_club == widget.idClub;
              }).toList();
              final List<Player> playersBuy = players.where((player) {
                return player.id_club != widget.idClub;
              }).toList();
              return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      'Transfer Page',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // bottom: TabBar(
                    //   controller: _tabController,
                    //   tabs: [
                    //     Tab(text: 'Sell (${playersSell.length})'),
                    //     Tab(text: 'Buy (${playersBuy.length})'),
                    //   ],
                    // ),
                  ),
                  drawer: AppDrawer(),
                  body: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Cash: ',
                          style: const TextStyle(fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                              text: Provider.of<SessionProvider>(context)
                                  .selectedClub
                                  .cash_available
                                  .toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Provider.of<SessionProvider>(context)
                                            .selectedClub
                                            .cash_absolute >
                                        0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Available cash: ',
                          style: const TextStyle(fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                              text: Provider.of<SessionProvider>(context)
                                  .selectedClub
                                  .cash_available
                                  .toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Provider.of<SessionProvider>(context)
                                            .selectedClub
                                            .cash_available >
                                        0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: 'Sell (${playersSell.length})'),
                          Tab(text: 'Buy (${playersBuy.length})'),
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
                  ));
            }
          }
        });
  }

  Widget _playersTransferWidget(List<Player> players) {
    if (players.isEmpty) {
      return const Center(
        child: Text('No players'),
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
              return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayersPage(
                          inputCriteria: {
                            'Players': [player.id]
                          },
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${player.first_name[0]}.${player.last_name.toUpperCase()} ',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          player.getStatusRow(),
                        ],
                      ),
                      subtitle: Column(
                        children: [
                          player.getAgeWidget(),
                          player.getAvgStatsWidget(),
                        ],
                      ),
                      // You can add more widgets here to display additional information about the player
                    ),
                  ));
            },
          ),
        )
      ],
    );
  }
}
