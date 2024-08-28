import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/classes/player/players_sorting_function.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/transfer_bid.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/classes/player/player_card.dart';
import 'class/player.dart';
import '../../constants.dart';

class PlayersPage extends StatefulWidget {
  final Map<String, List<Object>> inputCriteria;
  final bool
      isReturningPlayer; // Should the page return the id of the player clicked ?

  const PlayersPage(
      {Key? key, required this.inputCriteria, this.isReturningPlayer = false})
      : super(key: key);

  static Route<void> route(Map<String, List<int>> inputCriteria) {
    return MaterialPageRoute(
      builder: (context) => PlayersPage(inputCriteria: inputCriteria),
    );
  }

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  late Stream<List<Player>> _playerStream;
  late Stream<List<Club>> _clubStream;
  late Stream<List<TransferBid>> _transferBids;

  @override
  void initState() {
    super.initState();

    // Stream to fetch players
    if (widget.inputCriteria.containsKey('Clubs')) {
      _playerStream = supabase
          .from('players')
          .stream(primaryKey: ['id'])
          .inFilter('id_club', widget.inputCriteria['Clubs']!)
          .order('date_birth', ascending: true)
          .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
    } else if (widget.inputCriteria.containsKey('Players')) {
      _playerStream = supabase
          .from('players')
          .stream(primaryKey: ['id'])
          .inFilter('id', widget.inputCriteria['Players']!)
          .order('date_birth', ascending: true)
          .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
    } else if (widget.inputCriteria.containsKey('Countries')) {
      throw ArgumentError('Not implemented yet');
    } else {
      throw ArgumentError('Invalid input type');
    }

    // Stream to fetch clubs from the list of clubs in the players list
    _clubStream = _playerStream.switchMap((players) {
      final clubIds = players.map((player) => player.idClub).toSet().toList();
      return supabase
          .from('clubs')
          .stream(primaryKey: ['id'])
          .inFilter('id', clubIds.cast<Object>())
          .map((maps) => maps.map((map) => Club.fromMap(map)).toList());
    });
    // Combine player and club streams
    _playerStream =
        _playerStream.switchMap((players) => _clubStream.map((clubs) {
              for (var player in players) {
                final clubData =
                    clubs.firstWhere((club) => club.id == player.idClub);
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
                  appBar: AppBar(
                    title: players.length == 1
                        // If only 1 player, show his name as title
                        ? players.first.getPlayerNames(context)
                        // Else show the number of players on the page
                        : Text(
                            '${players.length} Players',
                          ),
                    actions: [
                      // Navigate to previous page
                      goBackIconButton(context),
                      // Search for a player
                      Tooltip(
                        message: 'Search for a player',
                        child: IconButton(
                          onPressed: () {
                            // Add your action here
                          },
                          icon: Icon(Icons.search),
                        ),
                      ),
                      // Open the order and filter drawer
                      // filterAndOrderPlayersButton(players),
                      IconButton(
                          tooltip: 'Sort players by...',
                          onPressed: () {
                            showSortingOptions(context, setState, players);
                          },
                          // icon: Icon(Icons.sort)),
                          icon: Icon(Icons.align_horizontal_left_rounded)),
                    ],
                  ),
                  drawer: (widget.isReturningPlayer || players.length == 1)
                      ? null
                      : const AppDrawer(),
                  body: MaxWidthContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: players.length,
                            itemBuilder: (context, index) {
                              final Player player = players[index];
                              return InkWell(
                                onTap: () {
                                  if (widget.isReturningPlayer) {
                                    Navigator.of(context).pop(
                                        player); // Return the id of the player
                                  } else if (players.length > 1) {
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
                                  } else {
                                    // Handle logic for single player directly
                                  }
                                },
                                child: PlayerCard(
                                    player: player,
                                    index: players.length == 1 ? 0 : index + 1,
                                    isExpanded:
                                        players.length == 1 ? true : false),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ));
            }
          }
        });
  }

  // void showSortingOptions(BuildContext context, List<Player> players) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return ListView(
  //         padding: EdgeInsets.zero,
  //         children: <Widget>[
  //           DrawerHeader(
  //             decoration: BoxDecoration(
  //               color: Colors.blue,
  //             ),
  //             child: Text(
  //               'Sort Options',
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 24,
  //               ),
  //             ),
  //           ),
  //           ListTile(
  //             leading: Icon(Icons.cake_outlined),
  //             title: Text('Age Ascending'),
  //             onTap: () {
  //               setState(() {
  //                 players.sort((a, b) => a.dateBirth.compareTo(b.dateBirth));
  //               });
  //               Navigator.pop(context);
  //             },
  //           ),
  //           ListTile(
  //             leading: Icon(Icons.cake_outlined),
  //             title: Text('Age Descending'),
  //             onTap: () {
  //               setState(() {
  //                 players.sort((a, b) => b.dateBirth.compareTo(a.dateBirth));
  //               });
  //               Navigator.pop(context);
  //             },
  //           ),
  //           ListTile(
  //             leading: Icon(Icons.sort_by_alpha_outlined),
  //             title: Text('Last Name'),
  //             onTap: () {
  //               setState(() {
  //                 players.sort((a, b) => a.lastName.compareTo(b.lastName));
  //               });
  //               Navigator.pop(context);
  //             },
  //           ),
  //           ListTile(
  //             leading: Icon(Icons.sort_by_alpha_outlined),
  //             title: Text('First Name'),
  //             onTap: () {
  //               setState(() {
  //                 players.sort((a, b) => a.firstName.compareTo(b.firstName));
  //               });
  //               Navigator.pop(context);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
