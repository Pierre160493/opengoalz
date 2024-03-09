import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/widgets/appBar.dart';
import 'package:opengoalz/widgets/player_card_single.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../classes/player.dart';
import '../constants.dart';

class PlayerPage extends StatefulWidget {
  final int idPlayer;

  const PlayerPage({Key? key, required this.idPlayer}) : super(key: key);

  static Route<void> route(int idPlayer) {
    return MaterialPageRoute<void>(
      builder: (context) => PlayerPage(idPlayer: idPlayer),
    );
  }

  @override
  State<PlayerPage> createState() => _HomePageState();
}

class _HomePageState extends State<PlayerPage> {
  late final Stream<List<Player>> _playerStream;

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;

    _playerStream = _fetchPlayersStream(myUserId, widget.idPlayer);

    super.initState();
  }

  Stream<List<Player>> _fetchPlayersStream(String myUserId, int idPlayer) {
    var query = supabase
        .from('view_players')
        .stream(primaryKey: ['id'])
        .eq('id', idPlayer)
        .order('created_at');

    return query.map((maps) => maps
        .map((map) => Player.fromMap(map: map, myUserId: myUserId))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Player>>(
        stream: _playerStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('ERROR: ${snapshot.error}'),
            );
          } else {
            final players = snapshot.data ?? [];
            if (players.isEmpty) {
              return const Center(
                child: Text('ERROR: No players found'),
              );
            }
            if (players.length != 1) {
              return Center(
                child: Text('ERROR: ${players.length} players found'),
              );
            } else {
              return Scaffold(
                appBar: CustomAppBar(
                  pageName:
                      '${players[0].first_name} ${players[0].last_name.toUpperCase()}',
                ),
                // drawer: const AppDrawer(),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return PlayerCardSingle(player: player);
                        },
                      ),
                    )
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        MediaQuery.of(context).size.width -
                            200, // Adjusted to position the menu at the top right of the BottomNavigationBar
                        MediaQuery.of(context).size.height -
                            kBottomNavigationBarHeight -
                            150, // Adjusted to position the menu above the BottomNavigationBar
                        0,
                        0,
                      ),
                      items: [
                        const PopupMenuItem<String>(
                          value: 'Sell',
                          child: Row(
                            children: [
                              Icon(Icons.attach_money),
                              SizedBox(width: 8),
                              Text('Sell'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Fire',
                          child: Row(
                            children: [
                              Icon(Icons.exit_to_app),
                              SizedBox(width: 8),
                              Text('Fire'),
                            ],
                          ),
                        ),
                      ],
                    ).then((value) async {
                      // Handle the onPressed action for each selected action
                      if (value != null) {
                        switch (value) {
                          case 'Sell':
                            // Add the onPressed action for Action 1
                            // This is just a placeholder, you should replace it with your actual action
                            // For example:
                            // performAction1();
                            break;
                          case 'Fire':
                            print(players[0].id);
                            try {
                              DateTime date_firing =
                                  DateTime.now().add(const Duration(days: 7));
                              await supabase.from('players').update({
                                'date_firing': date_firing.toIso8601String()
                              }).match({'id': players[0].id});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          '${players[0].first_name} ${players[0].last_name.toUpperCase()}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          ' has 7 days to pack his stuff or change your mind !',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              print('PG: Seems OK');
                            } on PostgrestException catch (error) {
                              print(error);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error
                                      .code!), // Display the PostgREST error code
                                ),
                              );
                            }
                            print("PG: Fin");
                            break;
                          // Add more cases for additional actions if needed
                        }
                      }
                    });
                  },
                  child: const Icon(Icons.add),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Add onPressed action for the first bottom navigation item
                        },
                        icon: const Icon(Icons.home),
                      ),
                      IconButton(
                        onPressed: () {
                          // Add onPressed action for the second bottom navigation item
                        },
                        icon: const Icon(Icons.accessibility_new),
                      ),
                      // Add more bottom navigation items as needed
                    ],
                  ),
                ),
              );
            }
          }
        });
  }
}
