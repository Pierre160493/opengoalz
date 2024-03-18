import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/pages/player_page.dart';
import 'package:opengoalz/widgets/appBar.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/player_card.dart';

import '../classes/player.dart';
import '../constants.dart';

class PlayersPage extends StatefulWidget {
  final int idClub;
  final bool
      isReturningId; // Should the page return the id of the player clicked ?
  const PlayersPage(
      {Key? key, required this.idClub, this.isReturningId = false})
      : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute(
      builder: (context) => PlayersPage(idClub: idClub),
    );
  }

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  late final Stream<List<Player>> _playerStream;
  late int _playersCount = 0; // Number of players
  String _selectedFilter = 'Age'; // Default filter by age

  @override
  void initState() {
    _playerStream = _fetchPlayersStream();

    // Listen to the stream and update the player count
    _playerStream.listen((players) {
      setState(() {
        _playersCount = players.length;
      });
    });

    super.initState();
  }

  Stream<List<Player>> _fetchPlayersStream() {
    var query = supabase
        .from('view_players')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.idClub)
        .order('created_at');

    // Apply filter based on selected criteria
    if (_selectedFilter == 'Age') {
      query = query.order('age', ascending: false);
    } else if (_selectedFilter == 'First Name') {
      query = query.order('first_name');
    } else if (_selectedFilter == 'Last Name') {
      query = query.order('last_name');
    }

    return query.map((maps) => maps.map((map) =>
        // Player.fromMap(map: map, myUserId: supabase.auth.currentUser!.id))
        Player.fromMap(map: map)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(
        title: Column(
          children: [
            Text(
              '${_playersCount.toString()} Players',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Club Name',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Add your action here
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              // Add your action here
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      drawer: widget.isReturningId ? null : const AppDrawer(),
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
                          _playerStream = _fetchPlayersStream();
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
                            widget.isReturningId
                                ? Navigator.of(context).pop(
                                    player.id) // Return the id of the player
                                : Navigator.push(
                                    context,
                                    PlayerPage.route(
                                        player.id), // Navigate to player page
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
