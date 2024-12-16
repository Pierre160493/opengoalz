import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/events/event.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/models/teamcomp/teamComp_main_widget.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/provider_user.dart';
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

  @override
  void initState() {
    super.initState();

    _gameStream = supabase
        .from('games')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idGame)
        .map((maps) =>
            maps.map((map) => Game.fromMap(map, widget.idSelectedClub)).first)
        .switchMap((Game game) {
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
        .switchMap((Game game) {
          if (game.idClubLeft == null) {
            return Stream.value(game);
          }
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('id', game.idClubLeft!)
              .map((maps) => maps.map((map) => Club.fromMap(map)).first)
              .map((Club club) {
                game.leftClub = club;
                return game;
              });
        })
        .switchMap((game) {
          if (game.idClubLeft == null) {
            return Stream.value(game);
          }
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('id', game.idClubRight!)
              .map((maps) => maps.map((map) => Club.fromMap(map)).first)
              .map((Club club) {
                game.rightClub = club;
                return game;
              });
        })
        .switchMap((game) {
          List<Object> clubIds = [];
          if (game.idClubLeft != null) {
            clubIds.add(game.idClubLeft!);
          }
          if (game.idClubRight != null) {
            clubIds.add(game.idClubRight!);
          }
          if (clubIds.isEmpty) {
            return Stream.value(game);
          }
          return supabase
              .from('games_teamcomp')
              .stream(primaryKey: ['id'])
              .inFilter('id_club', clubIds)
              .map((maps) => maps.map((map) => TeamComp.fromMap(map)).toList())
              .map((teamComps) {
                for (TeamComp teamComp in teamComps.where((TeamComp teamcomp) =>
                    teamcomp.seasonNumber == game.seasonNumber &&
                    teamcomp.weekNumber == game.weekNumber)) {
                  if (teamComp.idClub == game.idClubLeft) {
                    game.leftClub.teamComps.add(teamComp);
                  } else if (teamComp.idClub == game.idClubRight) {
                    game.rightClub.teamComps.add(teamComp);
                  }
                }
                return game;
              });
        })
        .switchMap((game) {
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
        .switchMap((game) {
          return supabase
              .from('players')
              .stream(primaryKey: ['id'])
              .inFilter('id', [
                ...game.leftClub.teamComps.first
                    .playersIdToListOfInt()
                    .where((id) => id != null)
                    .cast<int>(),
                ...game.rightClub.teamComps.first
                    .playersIdToListOfInt()
                    .where((id) => id != null)
                    .cast<int>()
              ])
              .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
              .map((players) {
                game.leftClub.teamComps.first.initPlayers(players
                    .where((player) => player.idClub == game.idClubLeft)
                    .toList());
                game.rightClub.teamComps.first.initPlayers(players
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
                }
                return game;
              });
        })
        .switchMap((Game game) {
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Game>(
        stream: _gameStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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

            return Scaffold(
              appBar: AppBar(
                  title:
                      game.getGameRow(context)), //Row presentation of the game
              body: Center(
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: 600), // Set your desired maximum width
                  child: DefaultTabController(
                      length: 3, // Number of tabs
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            tabs: [
                              buildTab(Icons.preview, 'Details'),
                              buildTab(Icons.reviews, 'Report'),
                              buildTab(Icons.group, 'Teams'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                game.getGameDetails(context),
                                game.getGameReport(context),
                                getTeamCompsTab(context, game),
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

  Widget buildTab(IconData icon, String text) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(width: 6), // Add some spacing between the icon and text
          Text(text),
        ],
      ),
    );
  }

  Widget getTeamCompsTab(BuildContext context, Game game) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTab(Icons.join_left, game.leftClub.name),
              buildTab(Icons.join_right, game.rightClub.name),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                /// Left Club TeamComp
                if (game.dateEnd == null &&
                    game.leftClub.id !=
                        Provider.of<SessionProvider>(context, listen: false)
                            .user!
                            .selectedClub!
                            .id)
                  Center(
                    child: Text(
                        'Only the team manager can see the teamcomp before the game is played'),
                  )
                else
                  // game.leftClub.teamComps.first.getTeamCompWidget(context),
                  TeamCompWidget(teamComp: game.leftClub.teamComps.first),

                /// Right Club TeamComp
                if (game.dateEnd == null &&
                    game.rightClub.id !=
                        Provider.of<SessionProvider>(context, listen: false)
                            .user!
                            .selectedClub!
                            .id)
                  Center(
                    child: Text(
                        'Only the team manager can see the teamcomp before the game is played'),
                  )
                else
                  // game.rightClub.teamComps.first.getTeamCompWidget(context),
                  TeamCompWidget(teamComp: game.rightClub.teamComps.first),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
