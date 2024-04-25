import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/transfer_bid.dart';
import 'package:opengoalz/player/class/player.dart';
import 'package:opengoalz/player/player_card.dart';
import 'package:opengoalz/player/players_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:rxdart/rxdart.dart';

import '../constants.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({Key? key}) : super(key: key);

  static Route<void> route(int idLeague) {
    return MaterialPageRoute<void>(
      builder: (context) => TransferPage(),
    );
  }

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  late final Stream<List<int>> _IdPlayersTransferStream;
  late Stream<List<Player>> _playerStream;
  late Stream<List<Club>> _clubStream;
  late Stream<List<TransferBid>> _transferBids;

  @override
  void initState() {
    super.initState();

    _IdPlayersTransferStream = supabase
        .from('transfers_bids')
        .stream(primaryKey: ['id'])
        .eq(
            'id_club',
            // Provider.of<SessionProvider>(context).selectedClub.id_club)
            1)
        .map((maps) =>
            maps.map((map) => map['id_player'] as int).toSet().toList());

    // Listen to the stream and print out the emitted values
    _IdPlayersTransferStream.listen((data) {
      print('Data emitted by _IdPlayersTransferStream: $data');
    });

    _playerStream = _IdPlayersTransferStream.asyncMap((idPlayers) {
      return supabase
          .from('players')
          .stream(primaryKey: ['id'])
          // .inFilter('id', idPlayers)
          .inFilter('id', [16, 17])
          .order('date_sell', ascending: true)
          .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
    }).asyncExpand((stream) => stream);

    _playerStream.listen((data) {
      print('Data emitted by _playerStream: $data');
    });

    // Stream to fetch clubs from the list of clubs in the players list
    _clubStream = _playerStream.switchMap((players) {
      final clubIds = players.map((player) => player.id_club).toSet().toList();
      return supabase
          .from('clubs')
          .stream(primaryKey: ['id'])
          .inFilter('id', clubIds.cast<Object>())
          .map((maps) => maps
              .map((map) => Club.fromMap(
                    map: map,
                    myUserId: supabase.auth.currentUser!.id,
                  ))
              .toList());
    });
    // Combine player and club streams
    _playerStream =
        _playerStream.switchMap((players) => _clubStream.map((clubs) {
              for (var player in players) {
                final clubData =
                    clubs.firstWhere((club) => club.id_club == player.id_club);
                player.club = clubData;
              }
              return players;
            }));

    // Stream to fetch transfer bids for each player
    _transferBids = _playerStream.switchMap((players) {
      final playerIds = players.map((player) => player.id).toSet().toList();
      return supabase
          .from('transfers_bids')
          .stream(primaryKey: ['id'])
          .inFilter('id_player', playerIds.cast<Object>())
          .order('count_bid', ascending: true)
          .map((maps) => maps.map((map) => TransferBid.fromMap(map)).toList());
    });

    // Combine player and transfer bids streams
    _playerStream =
        _playerStream.switchMap((players) => _transferBids.map((transferBids) {
              for (var player in players) {
                player.transferBids.clear();
                player.transferBids.addAll(
                    transferBids.where((bid) => bid.idPlayer == player.id));
              }
              return players;
            }));
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
            // final players = snapshot.data ?? [];
            final List<Player> players = (snapshot.data ?? []);
            if (players.isEmpty) {
              return const Center(
                child: Text('ERROR: No players found'),
              );
            } else {
              return Scaffold(
                  // backgroundColor: Colors.grey[700],
                  appBar: AppBar(
                    title: Column(
                      children: [
                        if (players.length == 1)
                          Text(players.last.last_name)
                        else
                          Text(
                            '${players.length} Players',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Text(
                          'Club Name',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    elevation: 0,
                    actions: [
                      IconButton(
                        onPressed: () {
                          // Add your action here
                        },
                        icon: Icon(Icons.search),
                      ),
                      PopupMenuButton<String>(
                        // icon: Icons.filter_alt_outlined,
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                              // value: 'sort_by_title',
                              child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: Colors.green,
                                size: 36,
                              ),
                              Text(' Sort Players By',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          )),
                          const PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'age_asc',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cake_outlined,
                                  color: Colors.green,
                                ),
                                Text(' Age '),
                                Icon(Icons.arrow_outward_outlined),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'age_desc',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cake_outlined,
                                  color: Colors.green,
                                ),
                                Text(' Age '),
                                Icon(Icons.arrow_downward),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'last_name',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.sort_by_alpha_outlined,
                                  color: Colors.green,
                                ),
                                Text(' Last Name'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'first_name',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.sort_by_alpha_outlined,
                                  color: Colors.green,
                                ),
                                Text(' First Name'),
                              ],
                            ),
                          ),
                          // Add other sorting options here
                        ],
                        onSelected: (String value) {
                          // Handle the selected option
                          if (value == 'age_asc') {
                            setState(() {
                              players.sort((a, b) =>
                                  b.date_birth.compareTo(a.date_birth));
                            });
                          } else if (value == 'age_desc') {
                            setState(() {
                              players.sort((a, b) =>
                                  a.date_birth.compareTo(b.date_birth));
                            });
                          } else if (value == 'last_name') {
                            setState(() {
                              players.sort(
                                  (a, b) => a.last_name.compareTo(b.last_name));
                            });
                          } else if (value == 'first_name') {
                            setState(() {
                              players.sort((a, b) =>
                                  a.first_name.compareTo(b.first_name));
                            });
                          } // Add other options as needed
                        },
                      ),
                    ],
                  ),
                  drawer: AppDrawer(),
                  body: Column(
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
                                      inputCriteria: {
                                        'Players': [player.id]
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  // Text('${index + 1}'),
                                  PlayerCard(
                                      player: player,
                                      number:
                                          players.length == 1 ? 0 : index + 1,
                                      isExpanded:
                                          players.length == 1 ? true : false),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ));
            }
          }
        });
  }
}
