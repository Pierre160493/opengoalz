import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:rxdart/rxdart.dart'; // Import the rxdart package
import 'package:opengoalz/pages/player_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/player_card.dart';
import '../classes/player/player.dart';
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
  late Stream<List<Player>> _playerStream;
  late Stream<List<Map>> _clubStream;

  @override
  void initState() {
    super.initState();

    // Stream to fetch players
    _playerStream = supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.idClub)
        .order('date_birth', ascending: true)
        .map((maps) => maps.map((map) => Player.fromMap(map)).toList());

    // Stream to fetch clubs
    _clubStream =
        supabase.from('clubs').stream(primaryKey: ['id']).map((maps) => maps
            .map((map) => {
                  'id_club': map['id'],
                  'name_club': map['name_club'],
                })
            .toList());

    // Combine player and club streams
    _playerStream =
        _playerStream.switchMap((players) => _clubStream.map((clubs) {
              for (var player in players) {
                final clubData = clubs
                    .firstWhere((club) => club['id_club'] == player.id_club);
                player.clubName = clubData['name_club'];
              }
              return players;
            }));
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
            } else {
              return Scaffold(
                  appBar: AppBar(
                    title: Column(
                      children: [
                        Text(
                          '${players.length} Players',
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
                          // _showFilterDialog();
                        },
                        icon: Icon(Icons.filter_list),
                      ),
                    ],
                  ),
                  drawer: widget.isReturningId ? null : const AppDrawer(),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final player = players[index];
                            return InkWell(
                              onTap: () {
                                widget.isReturningId
                                    ? Navigator.of(context).pop(player
                                        .id) // Return the id of the player
                                    : Navigator.push(
                                        context,
                                        PlayerPage.route(player
                                            .id), // Navigate to player page
                                      );
                              },
                              child: Column(
                                children: [
                                  Text('${player.first_name}'),
                                  Text('${player.last_name}'),
                                  Text(
                                      '${player.clubName ?? 'Unknown Club'}'), // Display club name
                                  PlayerCard(player: player, number: index + 1),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ));
            }
          }
        });
  }
}
