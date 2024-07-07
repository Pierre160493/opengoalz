import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/events/event.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/classes/game/game.dart';
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
  late final Stream<Club> _clubStream;
  late final Stream<List<Game>> _gamesStream;

  @override
  void initState() {
    /// Get the club
    _clubStream = supabase
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idClub)
        .map((maps) => Club.fromMap(
            map: maps.first, myUserId: supabase.auth.currentUser!.id));
    print(_clubStream);

    /// Get the games
    _gamesStream = _clubStream.switchMap((Club club) {
      return supabase
          .from('games')
          .stream(primaryKey: ['id'])
          .eq('id_league', club.id_league)
          // .eq('season_number', club.season_number)
          .map((maps) => maps.map((map) => Game.fromMap(map)).toList())

          /// Filter only the games for the club
          .map((games) => games
              .where((game) =>
                  game.idClubLeft == widget.idClub ||
                  game.idClubRight == widget.idClub)
              // .where((game) =>
              //     (game.idClubLeft == widget.idClub ||
              //         game.idClubRight == widget.idClub) &&
              //     game.seasonNumber == club.season_number)
              .toList())

          /// Order the games by date_start
          .map((games) {
            games.sort((a, b) =>
                a.dateStart.compareTo(b.dateStart)); // Order by date_start
            return games;
          })

          /// Get the clubs for the games
          .switchMap((List<Game> games) {
            return supabase
                .from('clubs')
                .stream(primaryKey: ['id'])
                .eq('id_league', club.id_league)
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
                    // print('Game:' +
                    //     game.id.toString() +
                    //     game.leftClub.club_name +
                    //     ' VS ' +
                    //     game.rightClub.club_name);
                  }
                  return games;
                });
          })
          .switchMap((List<Game> games) {
            return supabase
                .from('game_events')
                .stream(primaryKey: ['id'])
                .inFilter('id_game', games.map((game) => game.id).toList())
                .map((maps) =>
                    maps.map((map) => GameEvent.fromMap(map)).toList())
                .map((events) {
                  for (var game in games) {
                    game.events = events
                        .where((event) => event.idGame == game.id)
                        .toList();
                  }
                  return games;
                });
          });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Game>>(
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
              final List<Game> gamesCurrent = [];
              final List<Game> gamesIncoming = [];
              final List<Game> gamesPlayed = [];
              final List<Game> gamesHistoric = [];
              final List<Game> gamesFuture = [];

              DateTime now = DateTime.now();

              Club currentClub = games
                  .firstWhere((game) =>
                      game.leftClub.id_club == widget.idClub ||
                      game.rightClub.id_club == widget.idClub)
                  .leftClub;

              for (Game game in games) {
                if (game.seasonNumber < currentClub.season_number) {
                  gamesHistoric.add(game);
                } else if (game.seasonNumber > currentClub.season_number) {
                  gamesFuture.add(game);
                } else if (game.dateStart.isAfter(now) &&
                    game.dateStart
                        .isBefore(now.add(const Duration(hours: 3)))) {
                  gamesCurrent.add(game);
                } else if (game.isPlayed) {
                  gamesPlayed.add(game);
                } else {
                  gamesIncoming.add(game);
                }
              }
              return Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      Text('Games Page for '),
                      currentClub.getClubNameClickable(context),
                    ],
                  ),
                ),
                drawer: const AppDrawer(),
                body: MaxWidthContainer(
                  child: DefaultTabController(
                    length: gamesCurrent.length == 0 ? 2 : 3, // Number of tabs
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabBar(
                          tabs: [
                            Tab(text: 'Played (${gamesPlayed.length})'),
                            if (gamesCurrent.length > 0)
                              Tab(text: 'Current (${gamesCurrent.length})'),
                            Tab(text: 'Incoming (${gamesIncoming.length})'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              /// Played games
                              DefaultTabController(
                                length: 2, // Number of tabs
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TabBar(
                                      tabs: [
                                        Tab(
                                            text:
                                                'This season (${gamesPlayed.length})'),
                                        Tab(text: 'Previous seasons'),
                                      ],
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          _buildGameList(gamesIncoming),
                                          _buildGameList(gamesHistoric),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// Current games (if exists)
                              if (gamesCurrent.length > 0)
                                _buildGameList(gamesCurrent),

                              /// Incoming games
                              DefaultTabController(
                                length: 2, // Number of tabs
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TabBar(
                                      tabs: [
                                        Tab(
                                            text:
                                                'This season (${gamesIncoming.length})'),
                                        Tab(text: 'Next season'),
                                      ],
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          _buildGameList(gamesIncoming),
                                          _buildGameList(gamesFuture),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

  Widget _buildGameList(List<Game> games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final Game game = games[index];
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
