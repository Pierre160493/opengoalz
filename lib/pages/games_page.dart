import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';

import '../classes/game.dart';
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
  late final Stream<List<Game>> _gameStream;

  @override
  void initState() {
    _gameStream = supabase
        .from('view_games')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.idClub)
        .order('date_start', ascending: true)
        .map((maps) => maps.map((map) => Game.fromMap(map: map)).toList());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games Page'),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Game>>(
        stream: _gameStream,
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
              return const Center(
                child: Text('No games found'),
              );
            } else {
              final List<Game> gamesCurrent = [];
              final List<Game> gamesIncoming = [];
              final List<Game> gamesPlayed = [];

              DateTime now = DateTime.now();
              for (Game game in games) {
                if (game.dateStart.isAfter(now) &&
                    game.dateStart
                        .isBefore(now.add(const Duration(hours: 3)))) {
                  gamesCurrent.add(game);
                } else if (game.isPlayed) {
                  gamesPlayed.add(game);
                } else {
                  gamesIncoming.add(game);
                }
              }

              return DefaultTabController(
                length: gamesCurrent.length == 0 ? 2 : 3, // Number of tabs
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      tabs: [
                        if (gamesCurrent.length > 0)
                          Tab(text: 'Current (${gamesCurrent.length})'),
                        Tab(text: 'Incoming (${gamesIncoming.length})'),
                        Tab(text: 'Played (${gamesPlayed.length})'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          if (gamesCurrent.length > 0)
                            _buildGameList(gamesCurrent),
                          _buildGameList(gamesIncoming),
                          _buildGameList(gamesPlayed)
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildGameList(List<Game> games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(GamePage.route(game));
                },
                child: _buildGameDescription(game),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameDescription(Game game) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  ClubPage.route(game.idClubLeft),
                );
              },
              icon: widget.idClub == game.idClubLeft
                  ? const Icon(Icons.home_outlined)
                  : const Icon(Icons.sports_soccer),
              label: game.getLeftClubName(),
            ),
            SizedBox(width: 3),
            game.isPlayed ? game.getScoreRow() : Text('VS'),
            SizedBox(width: 3),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  ClubPage.route(game.idClubRight),
                );
              },
              icon: widget.idClub == game.idClubRight
                  ? const Icon(Icons.home_outlined)
                  : const Icon(Icons.sports_soccer),
              label: game.getRightClubName(),
            ),

            /// If the game is not played yet, show the button to set orders
            // if (!game.isPlayed)
            //   ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => game.isPlayed
            //                 ? GameResultPage(game: game)
            //                 : SetGameOrdersPage(game: game)),
            //       );
            //     },
            //     child: game.isPlayed
            //         ? const Text('View details')
            //         : const Text('Set Orders'),
            //   )
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: game.getDateRow(),
            ),
            game.getWeekDay(),
          ],
        ),
      ),
    );
  }
}
