import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/widgets/appBar.dart';
import 'package:opengoalz/widgets/appDrawer.dart';

import '../classes/game.dart';
import '../constants.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const GamesPage(),
    );
  }

  @override
  State<GamesPage> createState() => _HomePageState();
}

class _HomePageState extends State<GamesPage> {
  late final Stream<List<Game>> _gameStream;

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;

    _gameStream = supabase
        .from('view_games')
        .stream(primaryKey: ['id'])
        // .or(
        //   (q) => q.eq('idUserClubLeft', myUserId),
        //   (q) => q.eq('idUserClubRight', myUserId),
        // )
        .order('date_start')
        .map((maps) => maps
            .map((map) => Game.fromMap(map: map, myUserId: myUserId))
            .toList());

    // _gameStream = supabase
    //     .from('view_games')
    //     .select('*')
    //     .or('idUserClubLeft.eq.$myUserId,idUserClubRight.eq.$myUserId')
    //     .order('date_start')
    //     .map((maps) => maps
    //         .map((map) => Game.fromMap(map: map, myUserId: myUserId))
    //         .toList());

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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Number of Games: ${games.length}'),
                  const SizedBox(
                      height:
                          16), // Add some spacing between the text and the list
                  Expanded(
                    child: ListView.builder(
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text('${game.dateStart} ${game.id}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${game.nameClubLeft} VS ${game.nameClubRight}'),
                                Text('Date: ${game.dateStart}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}
