import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';

import '../classes/gameView.dart';
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
  late final Stream<List<GameView>> _gameStream;

  @override
  void initState() {
    _gameStream = supabase
        .from('view_games')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.idClub)
        .order('date_start', ascending: true)
        .map((maps) => maps.map((map) => GameView.fromMap(map: map)).toList());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games Page'),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<GameView>>(
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
              final List<GameView> gamesCurrent = [];
              final List<GameView> gamesIncoming = [];
              final List<GameView> gamesPlayed = [];

              DateTime now = DateTime.now();
              for (GameView game in games) {
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

  Widget _buildGameList(List<GameView> games) {
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
                  Navigator.of(context).push(GamePage.route(game.id));
                },
                // child: _buildGameDescription(game),
                child: game.getGameDetail(context),
              );
            },
          ),
        ),
      ],
    );
  }
}
