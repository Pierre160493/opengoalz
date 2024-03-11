import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/player.dart';
import 'package:opengoalz/widgets/player_card_single.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  Stream<List<Player>> _playerStream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    _playerStream = _fetchPlayersStream(widget.idPlayer);
  }

  Stream<List<Player>> _fetchPlayersStream(int idPlayer) {
    var query = supabase
        .from('view_players')
        .stream(primaryKey: ['id']).eq('id', idPlayer);

    return query
        .map((maps) => maps.map((map) => Player.fromMap(map: map)).toList());
  }

  // Method to update the stream and force the StreamBuilder to rebuild
  Stream<List<Player>> _updatePlayerStream() {
    _playerStream = _fetchPlayersStream(widget.idPlayer);
    setState(() {});
    return _playerStream;
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
              appBar: AppBar(
                title: Row(
                  children: [
                    Text(
                      '${players[0].first_name} ${players[0].last_name.toUpperCase()}  ',
                    ),
                    if (players[0].date_sell != null)
                      const Icon(
                        Icons.currency_exchange,
                        color: Colors.green,
                        size: 30,
                      ),
                    // Row(
                    //   children: [
                    //     const SizedBox(width: 12),
                    //     Container(
                    //       decoration: BoxDecoration(
                    //         // color: Colors.green,
                    //         borderRadius: BorderRadius.circular(
                    //             6), // Adjust the radius as needed
                    //       ),
                    //       child: const Row(
                    //         children: [
                    //           Icon(
                    //             Icons.currency_exchange,
                    //             color: Colors.green,
                    //           ),
                    //           // Text(
                    //           //   ' ${players[0].date_sell!.difference(DateTime.now()).inDays.toString()}d',
                    //           // ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    if (players[0].date_firing != null)
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(
                                  6), // Adjust the radius as needed
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.exit_to_app),
                                Text(
                                  '${players[0].date_firing!.difference(DateTime.now()).inDays.toString()}d',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (players[0].date_end_injury != null)
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(
                                  6), // Adjust the radius as needed
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_hospital_outlined),
                                Text(
                                    '${players[0].date_end_injury!.difference(DateTime.now()).inDays.toString()}d'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
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
                      players[0].date_firing == null
                          ? const PopupMenuItem<String>(
                              value: 'Fire',
                              child: Row(
                                children: [
                                  Icon(Icons.exit_to_app),
                                  SizedBox(width: 8),
                                  Text('Fire'),
                                ],
                              ),
                            )
                          : const PopupMenuItem<String>(
                              value: 'Unfire',
                              child: Row(
                                children: [
                                  Icon(Icons.cancel),
                                  SizedBox(width: 8),
                                  Text('Unfire'),
                                ],
                              ),
                            ),
                    ],
                  ).then((value) async {
                    if (value != null) {
                      switch (value) {
                        case 'Sell':
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: Text(
                                    'Are you sure you want to sell ${players[0].first_name} ${players[0].last_name.toUpperCase()} ?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                      // Execute firing action if user confirms
                                      try {
                                        DateTime dateSell = DateTime.now()
                                            .add(const Duration(days: 7));
                                        await supabase.from('players').update({
                                          'date_sell':
                                              dateSell.toIso8601String()
                                        }).match({'id': players[0].id});
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Center(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '${players[0].first_name} ${players[0].last_name.toUpperCase()}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    ' will be put in auction for 7 days !',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                        _playerStream = _updatePlayerStream();
                                        print('PG: Seems OK');
                                      } on PostgrestException catch (error) {
                                        print(error);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(error.code!),
                                          ),
                                        );
                                      }
                                      print("PG: Fin");
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              );
                            },
                          );
                          break;
                        case 'Fire':
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: Text(
                                    'Are you sure you want to fire ${players[0].first_name} ${players[0].last_name.toUpperCase()} ?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                      // Execute firing action if user confirms
                                      try {
                                        DateTime dateFiring = DateTime.now()
                                            .add(const Duration(days: 7));
                                        await supabase.from('players').update({
                                          'date_firing':
                                              dateFiring.toIso8601String()
                                        }).match({'id': players[0].id});
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Center(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '${players[0].first_name} ${players[0].last_name.toUpperCase()}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    ' has 7 days to pack his stuff or change your mind !',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                        _playerStream = _updatePlayerStream();
                                        print('PG: Seems OK');
                                      } on PostgrestException catch (error) {
                                        print(error);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(error.code!),
                                          ),
                                        );
                                      }
                                      print("PG: Fin");
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              );
                            },
                          );
                          break;
                        case 'Unfire':
                          try {
                            await supabase.from('players').update({
                              'date_firing':
                                  null // Set date_firing to null to "Unfire" the player
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
                                        ' has been unfired.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            // Fetch updated data by calling _fetchPlayersStream again
                            _playerStream = _updatePlayerStream();
                            print('Player unfired successfully.');
                          } on PostgrestException catch (error) {
                            print(error);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error.code!),
                              ),
                            );
                          }
                          break;
                        // Add more cases for additional actions if needed
                      }
                    }
                  });
                },
                child: const Icon(Icons.add),
              ),
              // floatingActionButtonLocation:
              //     FloatingActionButtonLocation.centerDocked,
              // bottomNavigationBar: BottomAppBar(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: [
              //       IconButton(
              //         onPressed: () {
              //           // Add onPressed action for the first bottom navigation item
              //         },
              //         icon: const Icon(Icons.home),
              //       ),
              //       IconButton(
              //         onPressed: () {
              //           // Add onPressed action for the second bottom navigation item
              //         },
              //         icon: const Icon(Icons.accessibility_new),
              //       ),
              //       // Add more bottom navigation items as needed
              //     ],
              //   ),
              // ),
            );
          }
        }
      },
    );
  }
}
