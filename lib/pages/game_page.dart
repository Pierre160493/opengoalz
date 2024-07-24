import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/events/event.dart';
import 'package:opengoalz/classes/game/class/game.dart';
import 'package:opengoalz/classes/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:rxdart/rxdart.dart';

class GamePage extends StatefulWidget {
  final int idGame;
  const GamePage({Key? key, required this.idGame}) : super(key: key);

  static Route<void> route(int idGame) {
    return MaterialPageRoute(
      builder: (context) => GamePage(idGame: idGame),
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
        .map((maps) => maps.map((map) => Game.fromMap(map)).first)
        .switchMap((game) {
          if (game.idClubLeft == null) {
            return Stream.value(game);
          }
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('id', game.idClubLeft!)
              .map((maps) => maps
                  .map((map) => Club.fromMap(
                      map: map, myUserId: supabase.auth.currentUser!.id))
                  .first)
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
              .map((maps) => maps
                  .map((map) => Club.fromMap(
                      map: map, myUserId: supabase.auth.currentUser!.id))
                  .first)
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
                    game.leftClub.teamcomp = teamComp;
                  } else if (teamComp.idClub == game.idClubRight) {
                    game.rightClub.teamcomp = teamComp;
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
                ...game.leftClub.teamcomp!
                    .toListOfInt()
                    .where((id) => id != null)
                    .cast<int>(),
                ...game.rightClub.teamcomp!
                    .toListOfInt()
                    .where((id) => id != null)
                    .cast<int>()
              ])
              .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
              .map((players) {
                game.leftClub.teamcomp!.initPlayers(players
                    .where((player) => player.idClub == game.idClubLeft)
                    .toList());
                game.rightClub.teamcomp!.initPlayers(players
                    .where((player) => player.idClub == game.idClubRight)
                    .toList());

                for (GameEvent event in game.events) {
                  if (event.idPlayer != null) {
                    try {
                      event.player = players
                          .firstWhere((player) => player.id == event.idPlayer);
                    } catch (e) {
                      print('No player found for event: $event');
                    }
                  }
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
                                game.getTeamcompsTab(context)
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
}
