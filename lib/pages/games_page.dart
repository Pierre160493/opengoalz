import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/pages/game_result_page.dart';
import 'package:opengoalz/pages/set_orders_page.dart';
import 'package:opengoalz/widgets/appBar.dart';
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
      appBar: const CustomAppBar(
        pageName: 'Games',
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
              final gamesIncoming =
                  games.where((game) => !game.isPlayed).toList();
              final gamesPlayed = games.where((game) => game.isPlayed).toList();

              gamesIncoming.sort((a, b) => a.dateStart.compareTo(b.dateStart));
              gamesPlayed.sort((a, b) => b.dateStart.compareTo(a.dateStart));

              return DefaultTabController(
                length: 2, // Number of tabs
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      tabs: [
                        // Tab(text: 'Current ()'),
                        Tab(text: 'Incoming (${gamesIncoming.length})'),
                        Tab(text: 'Played (${gamesPlayed.length})'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: gamesIncoming.length,
                                  itemBuilder: (context, index) {
                                    final game = gamesIncoming[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(GamePage.route(game));
                                      },
                                      child: _buildGameListItem(game),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: gamesPlayed.length,
                                  itemBuilder: (context, index) {
                                    final game = gamesPlayed[index];
                                    return _buildGameListItem(game);
                                  },
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildGameListItem(Game game) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: game.nameClubLeft,
                          style: TextStyle(
                            fontWeight: game.idUserClubLeft ==
                                    supabase.auth.currentUser!.id
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: game.isPlayed
                              ? '   ${game.goalsLeft} - ${game.goalsRight}   '
                              : ' vs ',
                          style: TextStyle(
                            color: (game.isPlayed == false ||
                                    game.goalsLeft == game.goalsRight)
                                ? Colors.white
                                : (game.isPlayed &&
                                        ((game.idUserClubLeft ==
                                                    supabase
                                                        .auth.currentUser!.id &&
                                                game.goalsLeft! >
                                                    game.goalsRight!) ||
                                            (game.idUserClubRight ==
                                                    supabase
                                                        .auth.currentUser!.id &&
                                                game.goalsLeft! <
                                                    game.goalsRight!)))
                                    ? Colors.green
                                    : Colors.red,
                            fontSize: 14,
                            fontWeight: game.isPlayed
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: game.nameClubRight,
                          style: TextStyle(
                              fontWeight: game.idUserClubRight ==
                                      supabase.auth.currentUser!.id
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => game.isPlayed
                          ? GameResultPage(game: game)
                          : SetGameOrdersPage(game: game)),
                );
              },
              child: game.isPlayed
                  ? const Text('View details')
                  : const Text('Set Orders'),
            )
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                      Icons.access_time_outlined), // Add your desired icon here
                  const SizedBox(
                      width:
                          4), // Add some spacing between the icon and the text
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Date: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text:
                              DateFormat('d MMMM HH:mm').format(game.dateStart),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'W${game.weekNumber}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
