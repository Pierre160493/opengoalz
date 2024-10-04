import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/players_sorting_function.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/searchTransferDialogBox.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/models/transfer_bid.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/models/player/player_card.dart';
import 'class/player.dart';
import '../../constants.dart';

class PlayersPage extends StatefulWidget {
  final PlayerSearchCriterias playerSearchCriterias;
  final bool
      isReturningPlayer; // Should the page return the id of the player clicked ?

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
  late Stream<List<Player>> _playerStream = Stream.value([]);
  late Stream<List<Club>> _clubStream = Stream.value([]);
  late Stream<List<TransferBid>> _transferBids = Stream.value([]);
  late PlayerSearchCriterias _currentSearchCriterias;

  @override
  void initState() {
    super.initState();

    _currentSearchCriterias = widget.playerSearchCriterias;
    _initializeStreams();
  }

  Future<void> _initializeStreams() async {
    List<int> playerIds = await _currentSearchCriterias.fetchPlayerIds();

    print(playerIds);

    _playerStream = supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .inFilter('id', playerIds)
        .map((maps) => maps.map((map) => Player.fromMap(map)).toList());

    // final data = await supabase
    //         .from('players')
    //         .select('id')
    //         .inFilter('id_multiverse', [1, 2, 3])
    //     // .inFilter('id', [1, 2])
    //     ;
    // print(data);
    // List<int> playerIds = data.map((item) => item['id'] as int).toList();

    // print('Number of players: ' + playerIds.length.toString());
    // print(playerIds);

    // String filterColumn;
    // List<int> filterList;

    // /// Check the input criteria and set the filter column and list
    // if (_currentSearchCriterias.idPlayer != null) {
    //   filterColumn = 'id';
    //   filterList = _currentSearchCriterias.idPlayer!;
    // } else if (_currentSearchCriterias.idClub != null) {
    //   filterColumn = 'id_club';
    //   filterList = _currentSearchCriterias.idClub!;
    // } else if (_currentSearchCriterias.countries.isNotEmpty) {
    //   filterColumn = 'id_country';
    //   filterList = _currentSearchCriterias.countries
    //       .map((country) => country.id)
    //       .toList();
    // } else if (_currentSearchCriterias.onTransferList == true) {
    //   filterColumn = 'date_bid_end';
    //   filterList = [];
    //   // } else if (_currentSearchCriterias.isFreePlayer == true) {
    //   //   filterColumn = 'date_bid_end';
    //   //   filterList = [];
    // } else if (_currentSearchCriterias.multiverse != null) {
    //   filterColumn = 'id_multiverse';
    //   filterList = [_currentSearchCriterias.multiverse!.id];
    // } else {
    //   throw Exception('No filter criteria found');
    // }

    // print('Player Search Criterias: $filterColumn');

    // // Stream to fetch players
    // if (filterColumn == 'date_bid_end') {
    //   _playerStream = supabase
    //       .from('players')
    //       .stream(primaryKey: ['id'])
    //       .gt(
    //           'date_bid_end',
    //           DateTime.now()
    //               .toIso8601String()) // Filter where date_bid_end is greater than now
    //       .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
    // } else {
    //   _playerStream = supabase
    //       .from('players')
    //       .stream(primaryKey: ['id'])
    //       .inFilter(filterColumn, filterList)
    //       .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
    // }

    // print('Player Search Criterias: $filterColumn');

    // // Stream to fetch players
    // _playerStream = _playerStream.map((players) {
    //   // Apply additional filtering
    //   players = players.where((Player player) {
    //     // if (player.id == 1) {
    //     //   //5098
    //     //   print('Player ID: ${player.id}');
    //     //   print('Player Date Bid End: ${player.dateBidEnd}');
    //     //   print('Player idClub: ${player.idClub}');
    //     // }

    //     /// Filter with the Club ID
    //     if (_currentSearchCriterias.idClub != null) {
    //       if (!_currentSearchCriterias.idClub!.contains(player.idClub)) {
    //         return false;
    //       }
    //     }

    //     /// Filter with the countries
    //     if (widget.playerSearchCriterias.countries.isNotEmpty) {
    //       if (!widget.playerSearchCriterias.countries
    //           .map((country) => country.id)
    //           .contains(player.idCountry)) {
    //         return false;
    //       }
    //     }

    //     /// Filter with the multiverse
    //     if (_currentSearchCriterias.multiverse != null) {
    //       if (player.idMultiverse != _currentSearchCriterias.multiverse!.id) {
    //         return false;
    //       }
    //     }

    //     /// Filter with the player status

    //     if (_currentSearchCriterias.onTransferList) {
    //       if (player.dateBidEnd == null || player.idClub == null) {
    //         return false;
    //       }
    //     }
    //     // if (_currentSearchCriterias.isFreePlayer && player.idClub != null) {
    //     //   return false;
    //     // }

    //     /// If the age range is set, filter the players based on the age range
    //     if (player.age < _currentSearchCriterias.selectedMinAge ||
    //         player.age > _currentSearchCriterias.selectedMaxAge) {
    //       return false;
    //     }

    //     /// If the stats are set, filter the players based on the stats
    //     if (_currentSearchCriterias.stats.isNotEmpty) {
    //       for (var entry in _currentSearchCriterias.stats.entries) {
    //         var statName = entry.key;
    //         var range = entry.value;
    //         var playerStat;

    //         // Use a switch statement to fetch the stat based on the name
    //         switch (statName) {
    //           case 'keeper':
    //             playerStat = player.keeper;
    //             break;
    //           case 'defense':
    //             playerStat = player.defense;
    //             break;
    //           case 'passes':
    //             playerStat = player.passes;
    //             break;
    //           case 'playmaking':
    //             playerStat = player.playmaking;
    //             break;
    //           case 'winger':
    //             playerStat = player.winger;
    //             break;
    //           case 'scoring':
    //             playerStat = player.scoring;
    //             break;
    //           case 'freekick':
    //             playerStat = player.freekick;
    //             break;
    //           default:
    //             playerStat = null;
    //         }

    //         // Check if the player's stat is within the specified range
    //         if (range != null) {
    //           if (playerStat < range.start || playerStat > range.end) {
    //             return false;
    //           }
    //         }
    //       }
    //     }

    //     return true;
    //   }).toList();

    //   // Apply ordering
    //   players.sort((Player a, Player b) {
    //     return a.dateBirth.compareTo(b.dateBirth);
    //   });

    //   return players;
    // });

    // Stream to fetch clubs from the list of clubs in the players list
    _clubStream = _playerStream.switchMap((players) {
      // final clubIds = players.map((player) => player.idClub).toSet().toList();
      final clubIds = players
          .map((player) => player.idClub)
          .where((id) => id != null)
          .toSet()
          .toList();

      if (clubIds.isEmpty) {
        return Stream.value([]);
      }

      return supabase
          .from('clubs')
          .stream(primaryKey: ['id'])
          .inFilter('id', clubIds.cast<Object>())
          .map((maps) => maps
              .map((map) => Club.fromMap(map))
              .toList()); // Handle empty stream
    });
    // Combine player and club streams
    _playerStream = _playerStream
        .switchMap((players) => _clubStream.map((List<Club> clubs) {
              for (var player
                  in players.where((player) => player.idClub != null)) {
                final clubData =
                    clubs.firstWhere((Club club) => club.id == player.idClub);
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

            return Scaffold(
                appBar: AppBar(
                  title: players.isEmpty
                      ? Text('No Players Found')
                      : players.length == 1
                          // If only 1 player, show his name as title
                          ? players.first.getPlayerNames(context)
                          // Else show the number of players on the page
                          : Text(
                              '${players.length} Players',
                            ),
                  actions: [
                    // Navigate to previous page
                    goBackIconButton(context),
                    // Search for a player only if the input criteria is not a simple case

                    IconButton(
                      tooltip: 'Modify Search Criterias',
                      onPressed: () {
                        showDialog<PlayerSearchCriterias>(
                          context: context,
                          builder: (BuildContext context) {
                            return playerSearchDialogBox(
                              inputPlayerSearchCriterias:
                                  _currentSearchCriterias,
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
                                        playerSearchCriterias:
                                            PlayerSearchCriterias(
                                                idPlayer: [player.id]),
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
        });
  }
}
