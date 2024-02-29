import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/widgets/appBar.dart';
import 'package:opengoalz/widgets/appDrawer.dart';

import '../classes/player.dart';
import '../constants.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const PlayersPage(),
    );
  }

  @override
  State<PlayersPage> createState() => _HomePageState();
}

class _HomePageState extends State<PlayersPage> {
  late final Stream<List<Player>> _playerStream;

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;

    _playerStream = supabase
        .from('view_players')
        .stream(primaryKey: ['id'])
        .eq('id_user', myUserId)
        .order('created_at')
        .map((maps) => maps
            .map((map) => Player.fromMap(map: map, myUserId: myUserId))
            .toList());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        pageName: 'Players',
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Player>>(
        stream: _playerStream,
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
            final players = snapshot.data ?? [];
            if (players.isEmpty) {
              return const Center(
                child: Text('No players found'),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Number of players: ${players.length}'),
                  const SizedBox(
                      height:
                          16), // Add some spacing between the text and the list
                  Expanded(
                    child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(
                                '${player.first_name} ${player.last_name}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Age: ${player.age}'),
                                Text('Date of Birth: ${player.date_birth}'),
                                Text('Club: ${player.club_name}'),
                                Text('Username: ${player.username}'),
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
