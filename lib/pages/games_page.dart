import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/events/event.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/game/class/gameClass.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';

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
  late final Stream<List<GameClass>> _gamesStream;
  late final Stream<List<GameClass>> _gamesStreamLeft;
  late final Stream<List<GameClass>> _gamesStreamRight;

  @override
  void initState() {
    _gamesStreamLeft = supabase
        .from('games')
        .stream(primaryKey: ['id'])
        .eq('id_club_left', widget.idClub)
        .map((maps) => maps.map((map) => GameClass.fromMap(map)).toList());

    _gamesStreamRight = supabase
        .from('games')
        .stream(primaryKey: ['id'])
        .eq('id_club_right', widget.idClub)
        .map((maps) => maps.map((map) => GameClass.fromMap(map)).toList());

    // Merge the two streams and fetch additional data for each game
    _gamesStream = Rx.merge([_gamesStreamLeft, _gamesStreamRight])
        .flatMap((games) => Stream.fromIterable(games))
        .switchMap((game) {
      final leftClubStream = supabase
          .from('clubs')
          .stream(primaryKey: ['id'])
          .eq('id', game.idClubLeft)
          .map((maps) => maps
              .map((map) => Club.fromMap(
                  map: map, myUserId: supabase.auth.currentUser!.id))
              .toList());

      final rightClubStream = supabase
          .from('clubs')
          .stream(primaryKey: ['id'])
          .eq('id', game.idClubRight)
          .map((maps) => maps
              .map((map) => Club.fromMap(
                  map: map, myUserId: supabase.auth.currentUser!.id))
              .toList());

      final eventStream = supabase
          .from('game_events')
          .stream(primaryKey: ['id'])
          .eq('id_game', game.id)
          .map((maps) => maps.map((map) => GameEvent.fromMap(map)).toList());

      return Rx.combineLatest3(leftClubStream, rightClubStream, eventStream,
          (leftClubs, rightClubs, events) {
        if (leftClubs.length != 1) {
          throw Exception(
              'DATABASE ERROR: ${leftClubs.length} club(s) found instead of 1 for the left club (with id: ${game.idClubLeft}) for the game with id: ${game.id}');
        }
        if (rightClubs.length != 1) {
          throw Exception(
              'DATABASE ERROR: ${rightClubs.length} club(s) found instead of 1 for the right club (with id: ${game.idClubRight}) for the game with id: ${game.id}');
        }
        game.leftClub = leftClubs.first;
        game.rightClub = rightClubs.first;
        game.events = events;
        return [game];
      });
    });

    // _gameStream = supabase
    //     .from('view_games')
    //     .stream(primaryKey: ['id'])
    //     .eq('id_club', widget.idClub)
    //     .order('date_start', ascending: true)
    //     .map((maps) => maps.map((map) => GameView.fromMap(map: map)).toList());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games Page'),
      ),
      drawer: const AppDrawer(),
      body: MaxWidthContainer(
        child: StreamBuilder<List<GameClass>>(
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
                return const Center(
                  child: Text('No games found'),
                );
              } else {
                final List<GameClass> gamesCurrent = [];
                final List<GameClass> gamesIncoming = [];
                final List<GameClass> gamesPlayed = [];

                DateTime now = DateTime.now();
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
                              //   _buildGameList(gamesCurrent),
                              // _buildGameList(gamesIncoming),
                              // _buildGameList(gamesPlayed)
                              Text('test'),
                            Text('test'),
                            Text('test'),
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
      ),
    );
  }

  // Widget _buildGameList(List<GameClass> games) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Expanded(
  //         child: ListView.builder(
  //           itemCount: games.length,
  //           itemBuilder: (context, index) {
  //             final game = games[index];
  //             return InkWell(
  //               onTap: () {
  //                 Navigator.of(context).push(GamePage.route(game.id));
  //               },
  //               // child: _buildGameDescription(game),
  //               child: game.getGameDetail(context),
  //             );
  //           },
  //           // leading: Text('test')
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
