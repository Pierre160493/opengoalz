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
  late Stream<List<Club>> _clubStream = Stream.value([]);
  late Stream<List<TransferBid>> _transferBids = Stream.value([]);
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

      var playerStream = supabase
          .from('players')
          .stream(primaryKey: ['id'])
          .inFilter('id', playerIds)
          .order('date_birth', ascending: false)
          .map((maps) {
            print('Fetched player maps: $maps');
            return maps.map((map) => Player.fromMap(map)).toList();
          })
          .handleError((error) {
            print('Error fetching player maps: $error');
          });

      print('Test1');

      // Sort players by bid end date if they are on transfer list
      if (_currentSearchCriterias.onTransferList) {
        playerStream = playerStream.map((players) {
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

      _clubStream = playerStream.switchMap((players) {
        final clubIds = players
            .map((player) => player.idClub)
            .where((id) => id != null)
            .toSet()
            .toList();
        // Continue with the rest of your logic

        if (clubIds.isEmpty) {
          return Stream.value([]);
        }

        return supabase
            .from('clubs')
            .stream(primaryKey: ['id'])
            .inFilter('id', clubIds.cast<Object>())
            .map((maps) {
              print('Fetched club maps: $maps');
              return maps.map((map) => Club.fromMap(map)).toList();
            })
            .handleError((error) {
              print('Error fetching club maps: $error');
            });
      });

      final combinedPlayerStream = playerStream
          .switchMap((players) => _clubStream.map((List<Club> clubs) {
                for (var player
                    in players.where((player) => player.idClub != null)) {
                  final clubData =
                      clubs.firstWhere((Club club) => club.id == player.idClub);
                  player.club = clubData;
                }
                return players;
              }));

      _transferBids = combinedPlayerStream.switchMap((players) {
        final playerIds = players.map((player) => player.id).toSet().toList();
        print('Fetched transfer bid player IDs: $playerIds');
        return supabase
            .from('transfers_bids')
            .stream(primaryKey: ['id'])
            .inFilter('id_player', playerIds.cast<Object>())
            .order('count_bid', ascending: true)
            .map((maps) {
              print('Fetched transfer bid maps: $maps');
              return maps.map((map) => TransferBid.fromMap(map)).toList();
            })
            .handleError((error) {
              print('Error fetching transfer bid maps: $error');
            });
      });

      final finalPlayerStream = combinedPlayerStream
          .switchMap((players) => _transferBids.map((transferBids) {
                for (var player in players) {
                  player.transferBids.clear();
                  player.transferBids.addAll(
                      transferBids.where((bid) => bid.idPlayer == player.id));
                }
                return players;
              }));

      finalPlayerStream.listen((players) {
        print('Final player stream data: $players');
        _playerStreamController.add(players);
      });
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
            final List<Player> players = (snapshot.data ?? []);
            print('StreamBuilder snapshot data: $players');

            return Scaffold(
                appBar: AppBar(
                  title: players.isEmpty
                      ? Text('No Players Found')
                      : players.length == 1
                          ? players.first.getPlayerNames(context)
                          : Text(
                              '${players.length} Players',
                            ),
                  actions: [
                    goBackIconButton(context),
                    if (_showReloadButton)
                      IconButton(
                        tooltip:
                            'Reload the list of players to see the latest changes',
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
                              onTap: () {
                                if (widget.isReturningPlayer) {
                                  Navigator.of(context).pop(player);
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
