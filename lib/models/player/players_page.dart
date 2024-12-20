import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/players_sorting_function.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/models/player/playerSearchDialogBox.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/transfer_bid.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/models/player/player_card.dart';
import 'class/player.dart';
import '../../constants.dart';

class PlayersPage extends StatefulWidget {
  final PlayerSearchCriterias playerSearchCriterias;
  final bool isReturningPlayer;

  const PlayersPage(
      {Key? key,
      required this.playerSearchCriterias,
      this.isReturningPlayer = false})
      : super(key: key);

  static Route<void> route(PlayerSearchCriterias playerSearchCriterias) {
    return MaterialPageRoute(
      builder: (context) =>
          PlayersPage(playerSearchCriterias: playerSearchCriterias),
    );
  }

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final StreamController<List<Player>> _playerStreamController =
      StreamController<List<Player>>();
  late Stream<List<Player>> _playerStream;
  late PlayerSearchCriterias _currentSearchCriterias;
  List<int> _previousPlayerIds = [];
  Timer? _timer;
  bool _showReloadButton = false;

  @override
  void initState() {
    super.initState();

    _currentSearchCriterias = widget.playerSearchCriterias;
    _playerStream = _playerStreamController.stream;
    _initializeStreams();
    _startPeriodicFetch();
  }

  void _startPeriodicFetch() {
    _timer = Timer.periodic(Duration(seconds: 15), (timer) async {
      List<int> newPlayerIds = await _currentSearchCriterias.fetchPlayerIds();
      if (!_listsAreEqual(newPlayerIds, _previousPlayerIds)) {
        setState(() {
          _showReloadButton = true;
        });
      }
    });
  }

  bool _listsAreEqual(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Future<void> _initializeStreams() async {
    try {
      List<int> playerIds = await _currentSearchCriterias.fetchPlayerIds();
      _previousPlayerIds = playerIds;
      print('Fetched player IDs: $playerIds');

      _playerStream = supabase

          /// Fetch the players
          .from('players')
          .stream(primaryKey: ['id'])
          .inFilter('id', playerIds)
          .order('date_birth', ascending: false)
          .map((maps) => maps.map((map) => Player.fromMap(map)).toList())

          /// Fetch their transfers bids
          .switchMap((List<Player> players) {
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
          })

          /// Fetch the clubs
          .switchMap((List<Player> players) {
            return supabase
                .from('clubs')
                .stream(primaryKey: ['id'])
                .inFilter(
                    'id',
                    players
                        .map((Player player) => player.idClub)
                        .where((idClub) => idClub != null)
                        .toSet()
                        .cast<Object>()
                        .toList())
                .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
                .map((List<Club> clubs) {
                  for (Player player
                      in players.where((player) => player.idClub != null)) {
                    player.club =
                        clubs.firstWhere((club) => club.id == player.idClub);
                  }
                  return players;
                });
          });

      // Sort players by bid end date if they are on transfer list
      if (_currentSearchCriterias.onTransferList) {
        _playerStream = _playerStream.map((players) {
          players.sort((Player a, Player b) {
            if (a.dateBidEnd == null) {
              return 1;
            } else if (b.dateBidEnd == null) {
              return -1;
            } else {
              return a.dateBidEnd!.compareTo(b.dateBidEnd!);
            }
          });
          return players;
        });
      }
    } catch (e) {
      print('Error initializing streams: $e');
    }
  }

  @override
  void dispose() {
    _playerStreamController.close();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeStreams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return StreamBuilder<List<Player>>(
            stream: _playerStream,
            builder: (context, streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (streamSnapshot.hasError) {
                return Center(child: Text('Error: ${streamSnapshot.error}'));
              } else {
                final List<Player> players = streamSnapshot.data ?? [];
                return _buildPlayersList(players);
              }
            },
          );
        }
      },
    );
  }

  Widget _buildPlayersList(List<Player> players) {
    return Scaffold(
        appBar: AppBar(
          title: players.isEmpty
              ? Text('No Players Found')
              : players.length == 1
                  ? players.first.getPlayerNameToolTip(context)
                  : Text(
                      '${players.length} Players',
                    ),
          actions: [
            goBackIconButton(context),
            if (_showReloadButton)
              IconButton(
                tooltip: 'Reload the list of players to see the latest changes',
                onPressed: () {
                  setState(() {
                    _showReloadButton = false;
                    _initializeStreams();
                  });
                },
                icon: Icon(Icons.refresh, color: Colors.green),
              ),
            IconButton(
              tooltip: 'Modify Search Criterias',
              onPressed: () {
                showDialog<PlayerSearchCriterias>(
                  context: context,
                  builder: (BuildContext context) {
                    return playerSearchDialogBox(
                      inputPlayerSearchCriterias: _currentSearchCriterias,
                    );
                  },
                ).then((playerSearchCriterias) {
                  if (playerSearchCriterias != null) {
                    setState(() {
                      _currentSearchCriterias = playerSearchCriterias;
                      _initializeStreams();
                    });
                  }
                });
              },
              icon: Icon(Icons.person_search),
            ),
            IconButton(
                tooltip: 'Sort players by...',
                onPressed: () {
                  showSortingOptions(context, setState, players);
                },
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
                      onTap: widget.isReturningPlayer || players.length > 1
                          ? () {
                              if (widget.isReturningPlayer) {
                                Navigator.of(context).pop(player);
                              } else if (players.length > 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayersPage(
                                      playerSearchCriterias:
                                          PlayerSearchCriterias(
                                        idPlayer: [player.id],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: PlayerCard(
                          player: player,
                          index: players.length == 1 ? null : index + 1,
                          isExpanded: players.length == 1 ? true : false),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return StreamBuilder<List<Player>>(
  //       stream: _playerStream,
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         } else if (snapshot.hasError) {
  //           return Center(
  //             child: Text('ERROR: ${snapshot.error}'),
  //           );
  //         } else {
  //           final List<Player> players = (snapshot.data ?? []);
  //           print('StreamBuilder snapshot data: $players');

  //           return Scaffold(
  //               appBar: AppBar(
  //                 title: players.isEmpty
  //                     ? Text('No Players Found')
  //                     : players.length == 1
  //                         ? players.first.getPlayerNameToolTip(context)
  //                         : Text(
  //                             '${players.length} Players',
  //                           ),
  //                 actions: [
  //                   goBackIconButton(context),
  //                   if (_showReloadButton)
  //                     IconButton(
  //                       tooltip:
  //                           'Reload the list of players to see the latest changes',
  //                       onPressed: () {
  //                         setState(() {
  //                           _showReloadButton = false;
  //                           _initializeStreams();
  //                         });
  //                       },
  //                       icon: Icon(Icons.refresh, color: Colors.green),
  //                     ),
  //                   IconButton(
  //                     tooltip: 'Modify Search Criterias',
  //                     onPressed: () {
  //                       showDialog<PlayerSearchCriterias>(
  //                         context: context,
  //                         builder: (BuildContext context) {
  //                           return playerSearchDialogBox(
  //                             inputPlayerSearchCriterias:
  //                                 _currentSearchCriterias,
  //                           );
  //                         },
  //                       ).then((playerSearchCriterias) {
  //                         if (playerSearchCriterias != null) {
  //                           setState(() {
  //                             _currentSearchCriterias = playerSearchCriterias;
  //                             _initializeStreams();
  //                           });
  //                         }
  //                       });
  //                     },
  //                     icon: Icon(Icons.person_search),
  //                   ),
  //                   IconButton(
  //                       tooltip: 'Sort players by...',
  //                       onPressed: () {
  //                         showSortingOptions(context, setState, players);
  //                       },
  //                       icon: Icon(Icons.align_horizontal_left_rounded)),
  //                 ],
  //               ),
  //               drawer: (widget.isReturningPlayer || players.length == 1)
  //                   ? null
  //                   : const AppDrawer(),
  //               body: MaxWidthContainer(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Expanded(
  //                       child: ListView.builder(
  //                         itemCount: players.length,
  //                         itemBuilder: (context, index) {
  //                           final Player player = players[index];
  //                           return InkWell(
  //                             onTap: () {
  //                               if (widget.isReturningPlayer) {
  //                                 Navigator.of(context).pop(player);
  //                               } else if (players.length > 1) {
  //                                 Navigator.push(
  //                                   context,
  //                                   MaterialPageRoute(
  //                                     builder: (context) => PlayersPage(
  //                                       playerSearchCriterias:
  //                                           PlayerSearchCriterias(
  //                                               idPlayer: [player.id]),
  //                                     ),
  //                                   ),
  //                                 );
  //                               } else {
  //                                 // Handle logic for single player directly
  //                               }
  //                             },
  //                             child: PlayerCard(
  //                                 player: player,
  //                                 index: players.length == 1 ? 0 : index + 1,
  //                                 isExpanded:
  //                                     players.length == 1 ? true : false),
  //                           );
  //                         },
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ));
  //         }
  //       });
  // }
}
