import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/events/event.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/game/class/gameClass.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';

import '../constants.dart';

class GamesPage extends StatefulWidget {
  final int idClub;
  const GamesPage({Key? key, required this.idClub}) : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute(
      builder: (context) => GamesPage(idClub: idClub),
    );
  }

  @override
  State<GamesPage> createState() => _HomePageState();
}

class _HomePageState extends State<GamesPage> {
  late final Stream<List<GameClass>> _gamesStream;
  late final Stream<List<GameClass>> _gamesStreamLeft;
  late final Stream<List<GameClass>> _gamesStreamRight;

  @override
  void initState() {
    _gamesStream = supabase
            .from('games')
            .stream(primaryKey: ['id'])
            .eq('id_club_left', widget.idClub)
            .map((maps) => maps.map((map) => GameClass.fromMap(map)).toList())
            .switchMap((games) {
              print('Number of games: ' + games.length.toString());

              final gameStream = supabase
                  .from('clubs')
                  .stream(primaryKey: ['id'])
                  .inFilter('id', games.map((game) => game.idClubLeft).toList())
                  .map((maps) => maps
                      .map((map) => Club.fromMap(
                          map: map, myUserId: supabase.auth.currentUser!.id))
                      .toList());
              return supabase
                  .from('games')
                  .stream(primaryKey: ['id'])
                  .eq('id_club_right', widget.idClub)
                  .map((maps) =>
                      maps.map((map) => GameClass.fromMap(map)).toList())
                  .map((games2) {
                    for (var game in games2) {
                      games.add(game);
                    }
                    // Order by game date
                    games.sort((a, b) => a.dateStart.compareTo(b.dateStart));
                    return games;
                  });
            })
            .switchMap((games) {
              print('Number of games: ' + games.length.toString());
              return supabase
                  .from('clubs')
                  .stream(primaryKey: ['id'])
                  // .inFilter('id', games.map((game) => game.idClubLeft).toList())
                  .inFilter(
                      'id',
                      games
                          .expand((game) => [game.idClubLeft, game.idClubRight])
                          .toSet() // Convert to set to remove duplicates
                          .toList()) // Convert to list to be able to use inFilter
                  .map((maps) => maps
                      .map((map) => Club.fromMap(
                          map: map, myUserId: supabase.auth.currentUser!.id))
                      .toList())
                  .map((clubs) {
                    for (var game in games) {
                      game.leftClub = clubs.firstWhere(
                          (club) => club.id_club == game.idClubLeft,
                          orElse: () => throw Exception(
                              'DATABASE ERROR: Club not found for the left club with id: ${game.idClubLeft} for the game with id: ${game.id}'));
                      ;
                      game.rightClub = clubs.firstWhere(
                          (club) => club.id_club == game.idClubRight,
                          orElse: () => throw Exception(
                              'DATABASE ERROR: Club not found for the right club with id: ${game.idClubRight} for the game with id: ${game.id}'));
                      ;
                      print('Game:' +
                          game.id.toString() +
                          game.leftClub.club_name +
                          ' VS ' +
                          game.rightClub.club_name);
                    }
                    return games;
                  });
            })
            .switchMap((games) {
              final eventStream = supabase
                  .from('game_events')
                  .stream(primaryKey: ['id'])
                  .inFilter('id_game', games.map((game) => game.id).toList())
                  .map((maps) =>
                      maps.map((map) => GameEvent.fromMap(map)).toList());
              return eventStream.map((events) {
                for (var game in games) {
                  game.events =
                      events.where((event) => event.idGame == game.id).toList();
                }
                return games;
              });
            })
        // .switchMap((games) {
        //   final playerIds = [
        //     for (var game in games)
        //       ...game.leftClub.teamcomp!
        //           .toListOfInt()
        //           .where((id) => id != null)
        //           .cast<int>(),
        //     for (var game in games)
        //       ...game.rightClub.teamcomp!
        //           .toListOfInt()
        //           .where((id) => id != null)
        //           .cast<int>(),
        //   ];

        //   return supabase
        //       .from('players')
        //       .stream(primaryKey: ['id'])
        //       .inFilter('id', playerIds)
        //       .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
        //       .map((players) {
        //         for (var game in games) {
        //           game.leftClub.teamcomp!.initPlayers(players
        //               .where((player) => player.idClub == game.idClubLeft)
        //               .toList());
        //           game.rightClub.teamcomp!.initPlayers(players
        //               .where((player) => player.idClub == game.idClubRight)
        //               .toList());

        //           for (GameEvent event in game.events) {
        //             if (event.idPlayer != null) {
        //               try {
        //                 event.player = players.firstWhere(
        //                     (player) => player.id == event.idPlayer);
        //               } catch (e) {
        //                 print('No player found for event: $event');
        //               }
        //             }
        //           }
        //         }
        //         return games;
        //       });
        // })
        ;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GameClass>>(
        stream: _gamesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final games = snapshot.data ?? [];
            if (games.isEmpty) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      'Empty Games Page for club with id: ${widget.idClub}'),
                ),
                drawer: const AppDrawer(),
                body: Center(
                  child:
                      Text('No games found for club with id ${widget.idClub}'),
                ),
              );
            } else {
              final List<GameClass> gamesCurrent = [];
              final List<GameClass> gamesIncoming = [];
              final List<GameClass> gamesPlayed = [];
              final List<GameClass> gamesHistoric = [];

              DateTime now = DateTime.now();
              Club? currentClub = null;
              for (GameClass game in games) {
                if (game.dateStart.isAfter(now) &&
                    game.dateStart
                        .isBefore(now.add(const Duration(hours: 3)))) {
                  gamesCurrent.add(game);
                } else if (game.isPlayed) {
                  gamesPlayed.add(game);
                } else {
                  gamesIncoming.add(game);
                }
                if (currentClub == null) {
                  if (game.leftClub.id_club == widget.idClub)
                    currentClub = game.leftClub;
                  else if (game.rightClub.id_club == widget.idClub)
                    currentClub = game.rightClub;
                }
              }
              if (currentClub == null) {
                return Scaffold(
                  appBar: AppBar(
                    title:
                        Text('Games Page for club with id: ${widget.idClub}'),
                  ),
                  drawer: const AppDrawer(),
                  body: Center(
                    child: Text(
                        'No games found for club with id ${widget.idClub}'),
                  ),
                );
              }
              return Scaffold(
                appBar: AppBar(
                  title: Text('Games Page for: ${currentClub.club_name}'),
                ),
                drawer: const AppDrawer(),
                body: MaxWidthContainer(
                  child: DefaultTabController(
                    length: gamesCurrent.length == 0 ? 3 : 4, // Number of tabs
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabBar(
                          tabs: [
                            if (gamesCurrent.length > 0)
                              Tab(text: 'Current (${gamesCurrent.length})'),
                            Tab(text: 'Incoming (${gamesIncoming.length})'),
                            Tab(text: 'Played (${gamesPlayed.length})'),
                            Tab(text: 'Historic'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              if (gamesCurrent.length > 0)
                                _buildGameList(gamesCurrent),
                              _buildGameList(gamesIncoming),
                              _buildGameList(gamesPlayed),
                              Text('test'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
        });
  }

  Widget _buildGameList(List<GameClass> games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final GameClass game = games[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(GamePage.route(game.id));
                },
                // child: _buildGameDescription(game),
                child: game.getGameDetails(context),
              );
            },
            // leading: Text('test')
          ),
        ),
      ],
    );
  }
}
