import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/pages/player_page.dart';
import 'package:opengoalz/widgets/appBar.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/player_card.dart';

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
  late int _playersCount = 0; // Number of players
  String _selectedFilter = 'Age'; // Default filter by age

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;

    _playerStream = _fetchPlayersStream(myUserId);

    // Listen to the stream and update the player count
    _playerStream.listen((players) {
      setState(() {
        _playersCount = players.length;
      });
    });

    super.initState();
  }

  Stream<List<Player>> _fetchPlayersStream(String myUserId) {
    var query = supabase
        .from('view_players')
        .stream(primaryKey: ['id'])
        .eq('id_user', myUserId)
        .order('created_at');

    // Apply filter based on selected criteria
    if (_selectedFilter == 'Age') {
      query = query.order('age', ascending: false);
    } else if (_selectedFilter == 'First Name') {
      query = query.order('first_name');
    } else if (_selectedFilter == 'Last Name') {
      query = query.order('last_name');
    }

    return query.map((maps) => maps
        .map((map) => Player.fromMap(map: map, myUserId: myUserId))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        pageName: '${_playersCount.toString()} Players',
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
              child: Text('ERROR: ${snapshot.error}'),
            );
          } else {
            final players = snapshot.data ?? [];
            if (players.isEmpty) {
              return const Center(
                child: Text('ERROR: No players found'),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Filter by: '),
                      DropdownButton<String>(
                        value: _selectedFilter,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFilter = newValue!;
                          });
                          // Update the stream query based on the new filter
                          _playerStream = _fetchPlayersStream(
                              supabase.auth.currentUser!.id);
                        },
                        items: <String>['Age', 'First Name', 'Last Name']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Text(
                    'Number of players: ${players.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Expanded(
                  //   child: ListWheelScrollView.useDelegate(
                  //     itemExtent: 150, //
                  //     diameterRatio: 5, //
                  //     // useMagnifier: true, //
                  //     magnification: 1.25, //
                  //     physics: const FixedExtentScrollPhysics(),
                  //     childDelegate: ListWheelChildBuilderDelegate(
                  //       builder: (context, index) {
                  //         if (index < 0 || index >= players.length) return null;
                  //         final player = players[index];
                  //         return PlayerCard(player: player);
                  //       },
                  //       childCount: players.length,
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        return InkWell(
                          onTap: () {
                            // Navigate to player page
                            Navigator.push(
                              context,
                              PlayerPage.route(player
                                  .id), // Call the route method with the player ID
                            );
                          },
                          child: PlayerCard(player: player),
                        );
                      },
                    ),
                  )
                ],
              );
            }
          }
        },
      ),
    );
  }
}
