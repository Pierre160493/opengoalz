import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/events/event.dart';
import 'package:opengoalz/classes/game/game.dart';
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
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('id', game.idClubLeft)
              .map((maps) => maps
                  .map((map) => Club.fromMap(
                      map: map, myUserId: supabase.auth.currentUser!.id))
                  .toList())
              .map((clubs) {
                if (clubs.length != 1) {
                  throw Exception(
                      'DATABASE ERROR: ${clubs.length} club(s) found instead of 1 for the left club (with id: ${game.idClubLeft}) for the game with id: ${game.id}');
                }
                game.leftClub = clubs.first;
                return game;
              });
        })
        .switchMap((game) {
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('id', game.idClubRight)
              .map((maps) => maps
                  .map((map) => Club.fromMap(
                      map: map, myUserId: supabase.auth.currentUser!.id))
                  .toList())
              .map((clubs) {
                if (clubs.length != 1) {
                  throw Exception(
                      'DATABASE ERROR: ${clubs.length} club(s) found instead of 1 for the right club (with id: ${game.idClubRight}) for the game with id: ${game.id}');
                }
                game.rightClub = clubs.first;
                return game;
              });
        })
        .switchMap((game) {
          return supabase
              .from('games_teamcomp')
              .stream(primaryKey: ['id'])
              .eq('id_game', game.id)
              .map((maps) => maps.map((map) => TeamComp.fromMap(map)).toList())
              .map((teamComps) {
                if (teamComps.length != 2) {
                  throw Exception(
                      'DATABASE ERROR: ${teamComps.length} teamcomps found instead of 2 for game with id: ${game.id}');
                }
                for (TeamComp teamComp in teamComps) {
                  if (teamComp.idClub == game.idClubLeft) {
                    game.leftClub.teamcomp = teamComp;
                  } else if (teamComp.idClub == game.idClubRight) {
                    game.rightClub.teamcomp = teamComp;
                  } else {
                    throw Exception(
                        'DATABASE ERROR: Teamcomp with id: ${teamComp.id} does not belong to any of the clubs of the game with id: ${game.id}');
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
                              Tab(text: 'Details'),
                              Tab(text: 'Report'),
                              Tab(text: 'Teams'),
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
}
