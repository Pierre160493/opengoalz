import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/models/transfer_bid.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/searchTransferDialogBox.dart';
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
            final List<Player> playersSell = players.where((player) {
              return player.idClub == widget.idClub;
            }).toList();
            final List<Player> playersBuy = players.where((player) {
              return player.idClub != widget.idClub;
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
                  actions: [
                    IconButton(
                      tooltip: 'Search for a player',
                      onPressed: () {
                        // _showSearchPlayerDialog(context);
                        // AssignPlayerOrClubDialog();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AssignPlayerOrClubDialog();
                          },
                        );
                      },
                      icon: Icon(Icons.person_search),
                    ),
                  ],
                ),
                drawer: AppDrawer(),
                body: MaxWidthContainer(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(iconMoney, color: Colors.green),
                        title: Text(NumberFormat.decimalPattern().format(
                          Provider.of<SessionProvider>(context)
                              .user!
                              .selectedClub!
                              .lisCash
                              .last,
                        )),
                        subtitle: Text(
                          'Available cash',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontStyle: FontStyle.italic,
                          ),
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
                  ),
                ));
            // }
          }
        });
  }

  Widget _playersTransferWidget(List<Player> players) {
    if (players.isEmpty) {
      return const Center(
        child: Text('You dont have any bids on any active transfer'),
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
                              '${player.firstName[0]}.${player.lastName.toUpperCase()} ',
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

  void _showSearchPlayerDialog(BuildContext context) {
    double selectedAge = 15.0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Players'),
          content: Column(
            children: [
              Text('This is where the search functionality will go.'),
              Slider(
                value: selectedAge,
                min: 15.0,
                max: 35.0,
                divisions: 200,
                label: selectedAge.toStringAsFixed(1),
                onChanged: (double value) {
                  setState(() {
                    selectedAge = value;
                  });
                },
              ),
              Text(
                'Selected Age: ${selectedAge.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }
}
