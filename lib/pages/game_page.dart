import 'package:flutter/material.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/events/event.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/game/gameCard.dart';
import 'package:opengoalz/models/game/gameDetailsTab.dart';
import 'package:opengoalz/models/game/gameStatsTab.dart';
import 'package:opengoalz/models/playerPosition.dart';
import 'package:opengoalz/models/playerStatsBest.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/models/teamcomp/teamCompMainTab.dart';
import 'package:opengoalz/models/teamcomp/teamCompTab.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class GamePage extends StatefulWidget {
  final int idGame;
  final int? idSelectedClub;
  const GamePage({Key? key, required this.idGame, this.idSelectedClub})
      : super(key: key);

  static Route<void> route(int idGame, int? idSelectedClub) {
    return MaterialPageRoute(
      builder: (context) =>
          GamePage(idGame: idGame, idSelectedClub: idSelectedClub),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<GamePage> {
  late Stream<Game> _gameStream;
  late final Profile currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = Provider.of<UserSessionProvider>(context, listen: false).user;

    _gameStream = supabase

        /// Fetch the game
        .from('games')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idGame)
        .map((maps) =>
            maps.map((map) => Game.fromMap(map, widget.idSelectedClub)).first)

        /// Fetch the description of the game
        .switchMap((Game game) {
          print('GameId: ${game.id}');
          return supabase
              .from('games_description')
              .stream(primaryKey: ['id'])
              .eq('id', game.idDescription)
              .map((maps) => maps.first)
              .map((map) {
                game.description = map['description'];
                return game;
              });
        })

        /// Fetch the left and right clubs
        .switchMap((Game game) {
          print('GameId1: ${game.id}');
          List<int?> clubIds = [game.idClubLeft, game.idClubRight];
          clubIds.removeWhere((id) => id == null);
          if (clubIds.isEmpty) {
            return Stream.value(game);
          }
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .inFilter('id', clubIds.cast<int>())
              .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
              .map((List<Club> clubs) {
                for (Club club in clubs) {
                  if (club.id == game.idClubLeft) {
                    game.leftClub = club;
                  } else if (club.id == game.idClubRight) {
                    game.rightClub = club;
                  }
                }
                return game;
              });
        })

        /// Fetch the teamcomps of the clubs
        .switchMap((game) {
          print('GameId3: ${game.id}');
          return supabase
              .from('games_teamcomp')
              .stream(primaryKey: ['id'])
              .eq('id_game', widget.idGame)
              .map((maps) => maps.map((map) => TeamComp.fromMap(map)).toList())
              .map((List<TeamComp> teamComps) {
                for (TeamComp teamComp in teamComps) {
                  if (teamComp.idClub == game.idClubLeft) {
                    // game.leftClub.teamComps.add(teamComp);
                    game.leftClub.selectedTeamComp = teamComp;
                  } else if (teamComp.idClub == game.idClubRight) {
                    // game.rightClub.teamComps.add(teamComp);
                    game.rightClub.selectedTeamComp = teamComp;
                  }
                }
                return game;
              });
        })

        /// Fetch the events of the game
        .switchMap((game) {
          print('GameId4: ${game.id}');
          return supabase
              .from('game_events')
              .stream(primaryKey: ['id'])
              .eq('id_game', widget.idGame)
              .map((maps) => maps.map((map) => GameEvent.fromMap(map)).toList())
              .map((events) {
                game.events = events;
                return game;
              });
        })

        /// Fetch the players of the teamcomps
        .switchMap((game) {
          print('GameId52: ${game.id}');
          print([
            ...game.leftClub.selectedTeamComp!
                .playersIdToListOfInt()
                .where((id) => id != null)
                .cast<int>(),
            ...game.rightClub.selectedTeamComp!
                .playersIdToListOfInt()
                .where((id) => id != null)
                .cast<int>()
          ]);
          return supabase
              .from('players')
              .stream(primaryKey: ['id'])
              .inFilter('id', [
                ...game.leftClub.selectedTeamComp!
                    .playersIdToListOfInt()
                    .where((id) => id != null)
                    .cast<int>(),
                ...game.rightClub.selectedTeamComp!
                    .playersIdToListOfInt()
                    .where((id) => id != null)
                    .cast<int>()
              ])
              .map((maps) =>
                  maps.map((map) => Player.fromMap(map, currentUser)).toList())
              .map((players) {
                game.leftClub.selectedTeamComp!.initPlayers(players
                    .where((player) => player.idClub == game.idClubLeft)
                    .toList());
                game.rightClub.selectedTeamComp!.initPlayers(players
                    .where((player) => player.idClub == game.idClubRight)
                    .toList());

                for (GameEvent event in game.events) {
                  if (event.idPlayer != null) {
                    event.player = players
                        .firstWhere((player) => player.id == event.idPlayer);
                  }
                  if (event.idPlayer2 != null) {
                    event.player2 = players
                        .firstWhere((player) => player.id == event.idPlayer2);
                  }
                  if (event.idPlayer3 != null) {
                    event.player3 = players
                        .firstWhere((player) => player.id == event.idPlayer3);
                  }
                  print('GameId7: ${game.id}');
                }
                return game;
              });
        })

        /// Fetch the type of events with the description
        .switchMap((Game game) {
          print('GameId9: ${game.id}');
          return supabase
              .from('game_events_type')
              .stream(primaryKey: ['id'])
              .inFilter(
                  'id',
                  game.events
                      .map((GameEvent event) => event.idEventType)
                      .toList())
              .map((maps) {
                final eventTypeMap = {
                  for (var map in maps) map['id']: map['description']
                };
                return eventTypeMap;
              })
              .map((eventTypeMap) {
                for (GameEvent event in game.events) {
                  event.description = eventTypeMap[event.idEventType] ??
                      'ERROR: Description not found';
                }
                return game;
              });
        })

        /// If the game is played, fetch the players stats
        .switchMap((Game game) {
          print('GameId10: ${game.id}');
          if (game.isPlaying == false) {
            return supabase
                .from('game_player_stats_best')
                .stream(primaryKey: ['id'])
                .eq('id_game', game.id)
                .map((maps) => maps
                    .map((map) => GamePlayerStatsBest.fromMap(map))
                    .toList())
                .map((List<GamePlayerStatsBest> gamePlayerStatsBest) {
                  print(
                      "Number of players found for: gamePlayerStatsBest: ${gamePlayerStatsBest.length}");

                  // Create a map of player IDs to PlayerWithPosition objects for faster lookup
                  final playerMap = {
                    for (var playerWithPosition in [
                      ...game.leftClub.selectedTeamComp!.playersWithPosition,
                      ...game.rightClub.selectedTeamComp!.playersWithPosition
                    ])
                      playerWithPosition.id: playerWithPosition
                  };

                  // Loop through the players and check if they are in the teamcomp
                  for (GamePlayerStatsBest gamePlayerStat
                      in gamePlayerStatsBest) {
                    // Find the player in the teamcomp and add the stats
                    final playerWithPosition =
                        playerMap[gamePlayerStat.idPlayer];
                    if (playerWithPosition != null) {
                      playerWithPosition.player!.gamePlayerStatsBest =
                          gamePlayerStat;
                    }
                  }
                  return game;
                });
          } else {
            return Stream.value(game);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Game>(
        stream: _gameStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCircularAndText('Loading game...');
          } else if (snapshot.hasError) {
            return Center(
              child: Text('ERROR: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No data available'),
            );
          } else {
            final Game game = snapshot.data!;
            print('test ici');

            return Scaffold(
              appBar: AppBar(
                title: game.getGameResultRow(context),
                leading: goBackIconButton(context),
              ),
              body: Center(
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: maxWidth), // Set your desired maximum width
                  child: DefaultTabController(
                      length: 3, // Number of tabs
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            tabs: [
                              buildTabWithIcon(
                                  icon: Icons.preview, text: 'Details'),
                              buildTabWithIcon(
                                  icon: Icons.group, text: 'Teams'),
                              buildTabWithIcon(icon: iconStats, text: 'Stats'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _getGameDetails(context, game),
                                _getTeamCompsTab(context, game),
                                // Text('Teamcomp'),
                                _getGameStats(context, game),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            );
          }
        });
  }

  Widget _getGameDetails(BuildContext context, Game game) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(icon: Icons.preview, text: 'Details'),
              buildTabWithIcon(icon: Icons.description, text: 'Full Report'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                /// Details of the game
                Column(
                  children: [
                    getGameCardWidget(context, game),
                    formSpacer12,
                    buildListOfEvents(
                        context,
                        game.events
                            .where((GameEvent event) =>
                                event.eventType.toUpperCase() == 'GOAL')
                            .toList(),
                        game,
                        false),
                  ],
                ),

                /// Full report of the game
                Column(
                  children: [
                    formSpacer12,
                    game.getGameResultRow(context, isSpaceEvenly: true),
                    formSpacer12,
                    buildListOfEvents(context, game.events, game, true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTeamCompsTab(BuildContext context, Game game) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(icon: Icons.join_left, text: game.leftClub.name),
              buildTabWithIcon(
                  icon: Icons.join_right, text: game.rightClub.name),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                /// Teamcomps tab
                for (Club club in [game.leftClub, game.rightClub])
                  if (game.dateEnd == null &&
                      club.id != currentUser.selectedClub!.id)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.lock, size: 50, color: Colors.grey),
                          Text(
                              'Only the team manager can see the teamcomp before the game is played'),
                        ],
                      ),
                    )
                  else
                    TeamCompMainTab(
                        context, currentUser, club.selectedTeamComp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getGameStats(BuildContext context, Game game) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(icon: Icons.preview, text: 'Game Stats'),
              buildTabWithIcon(icon: Icons.description, text: 'Player Stats'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                /// Game stats
                gameStatsWidget(game),

                /// Players stats
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.construction, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('Work in progress',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
