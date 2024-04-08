import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart' as radar;
import 'package:opengoalz/classes/player/player.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/widgets/transfer_widget.dart';
import 'package:provider/provider.dart';
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

class _PlayerPageState extends State<PlayerPage>
    with SingleTickerProviderStateMixin {
  Stream<List<Player>> _playerStream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    _playerStream = _fetchPlayersStream(widget.idPlayer);
  }

  // Method to update the stream and force the StreamBuilder to rebuild
  void refreshView() {
    _playerStream = _fetchPlayersStream(widget.idPlayer);
    setState(() {});
  }

  Stream<List<Player>> _fetchPlayersStream(int idPlayer) {
    return supabase
        .from('view_players')
        .stream(primaryKey: ['id'])
        .eq('id', idPlayer)
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
            // return Scaffold(
            //     appBar: _buildAppBar(players[0]),
            //     body: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Expanded(
            //           child: ListView.builder(
            //             itemCount: players.length,
            //             itemBuilder: (context, index) {
            //               final player = players[index];
            //               return _buildPlayerCard(player);
            //             },
            //           ),
            //         )
            //       ],
            //     ),
            //     floatingActionButton: _buildFloatingActionButton(
            //         players[0]) //Floating Action Button
            //     );
            return DefaultTabController(
              length: 2, // Define the number of tabs
              child: Scaffold(
                  appBar: AppBar(
                    title: Row(
                      children: [
                        Text(
                          '${players[0].first_name[0]}.${players[0].last_name.toUpperCase()} ',
                        ),
                        players[0]
                            .getStatusRow() // Get the status of the player (transfer, fired, injured, etc...)
                      ],
                    ),
                    bottom: const TabBar(
                      tabs: [
                        Tab(text: 'Details'), // First tab
                        Tab(text: 'History'), // Second tab
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      _buildDetailsTab(players[0]), // First tab content
                      _buildStatsTab(players[0]), // Second tab content
                    ],
                  ),
                  floatingActionButton: _buildFloatingActionButton(
                      players[0]) //Floating Action Button
                  ),
            );
          }
        }
      },
    );
  }

  Widget _buildDetailsTab(Player player) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlayerCard(player),
                const SizedBox(
                    height: 24), // Add spacing between name and radar chart
                SizedBox(
                  width:
                      double.infinity, // Make radar chart fill available width
                  height: 240, // Adjust this value as needed
                  child: radar.RadarChart.dark(
                    ticks: const [25, 50, 75, 100],
                    features: const [
                      'Keeper',
                      'Defense',
                      'Passes',
                      'Playmaking',
                      'Winger',
                      'Scoring',
                      'Freekick',
                    ],
                    data: [
                      [
                        player.keeper,
                        player.defense,
                        player.playmaking,
                        player.passes,
                        player.winger,
                        player.scoring,
                        player.freekick,
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(Player player) {
    return Container(
      alignment: Alignment.center,
      child: Text('Stats tab content goes here'),
    );
  }

  Widget _buildPlayerCard(Player player) {
    final features = [
      player.keeper,
      player.defense,
      player.playmaking,
      player.passes,
      player.winger,
      player.scoring,
      player.freekick,
    ];

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player's name row
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Icon(
                  Icons.person_pin_outlined,
                  size: 36,
                ),
              ),
              Text(
                ' ${player.first_name} ${player.last_name.toUpperCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20, // Increase the font size here
                ),
              ),
              // const Spacer(), // Add Spacer widget to push CircleAvatar to the right
            ],
          ),
          const SizedBox(
            height: 12,
          ),

          /// Selling tile
          if (player.date_sell != null)
            PlayerTransferTile(
              player: player,
              // onBidCompleted: refreshView
            ), // Show the transfer tile
          const SizedBox(height: 6),

          /// Firing tile
          if (player.date_firing != null)
            Row(
              children: [
                StreamBuilder<int>(
                  stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
                  builder: (context, snapshot) {
                    final remainingTime =
                        player.date_firing!.difference(DateTime.now());
                    final daysLeft = remainingTime.inDays;
                    final hoursLeft = remainingTime.inHours.remainder(24);
                    final minutesLeft = remainingTime.inMinutes.remainder(60);
                    final secondsLeft = remainingTime.inSeconds.remainder(60);

                    return RichText(
                      text: TextSpan(
                        text: 'Will be fired in: ',
                        style: const TextStyle(),
                        children: [
                          if (daysLeft > 0) // Conditionally include days left
                            TextSpan(
                              text: '$daysLeft d, ',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          TextSpan(
                            text:
                                '$hoursLeft h, $minutesLeft m, $secondsLeft s',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          const SizedBox(height: 6),
          if (player.date_end_injury != null)
            player.getInjuryWidget(), // Show the injury tile
          player.getAgeWidget(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                ClubPage.route(player.id_club),
              );
            },
            child: player.getClubWidget(), // Display the ClubWidget
          ),
          player.getUserNameWidget(),
          player.getCountryWidget(),
          player.getAvgStatsWidget(),
          const SizedBox(
              height: 24), // Add spacing between name and radar chart
          SizedBox(
            width: double.infinity, // Make radar chart fill available width
            height: 240, // Adjust this value as needed
            child: radar.RadarChart.dark(
              ticks: const [25, 50, 75, 100],
              features: const [
                'Keeper',
                'Defense',
                'Passes',
                'Playmaking',
                'Winger',
                'Scoring',
                'Freekick',
              ],
              data: [features],
            ),
          ),
        ],
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton(Player player) {
    return FloatingActionButton(
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
            if (player.date_sell == null)
              const PopupMenuItem<String>(
                value: 'Sell',
                child: Row(
                  children: [
                    Icon(icon_transfers),
                    SizedBox(width: 8),
                    Text('Sell'),
                  ],
                ),
              ),
            if (player.date_sell == null) //Fire player only if not to sell
              player.date_firing == null
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
                _SellPlayer(player); //Sell Player
                break;
              case 'Fire':
                _FirePlayer(player); //Fire Player
                break;
              case 'Unfire':
                _UnFirePlayer(player); //Unfire Player
                break;
              // Add more cases for additional actions if needed
            }
          }
        });
      },
      child: const Icon(Icons.add),
    );
  }

  void showPlayerSnackBar(
      BuildContext context, Player player, String txtDescription) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Column(
            children: [
              Text(
                '${player.first_name} ${player.last_name.toUpperCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                txtDescription,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _SellPlayer(Player player) async {
    final TextEditingController _priceController =
        TextEditingController(text: '0'); // Initialize with default value

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (player.date_firing != null)
      showPlayerSnackBar(context, player,
          'cannot put to auction because player is being fired !');
    else
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to sell ${player.first_name} ${player.last_name.toUpperCase()} ?',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Start price',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              /// Cancel button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel'),
              ),

              /// Confirm button
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  try {
                    int? minimumPrice = int.tryParse(_priceController.text);
                    if (minimumPrice == null || minimumPrice < 0) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please enter a valid number for minimum price (should be a positive integer)'),
                        ),
                      );
                      return;
                    }
                    print("PG test ici");
                    print(player.id);
                    print(Provider.of<SessionProvider>(context, listen: false)
                        .selectedClub
                        .id_club);
                    await supabase.from('transfers_bids').insert({
                      'amount': minimumPrice,
                      'id_player': player.id,
                      'id_club':
                          Provider.of<SessionProvider>(context, listen: false)
                              .selectedClub
                              .id_club,
                    });
                    // showPlayerSnackBar(
                    //     context, player, 'will be put in auction for 7 days !');
                    // _playerStream = _updatePlayerStream();
                  } on PostgrestException catch (error) {
                    print(error);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(error.message),
                      ),
                    );
                  } catch (error) {
                    print(error);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('An unexpected error occurred.'),
                      ),
                    );
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
  }

  Future<void> _FirePlayer(Player player) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text(
              'Are you sure you want to fire ${player.first_name} ${player.last_name.toUpperCase()} ?'),
          actions: <Widget>[
            /// Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),

            /// Confirm Button
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Execute firing action if user confirms
                try {
                  DateTime dateFiring =
                      DateTime.now().add(const Duration(days: 7));
                  await supabase.from('players').update({
                    'date_firing': dateFiring.toIso8601String()
                  }).match({'id': player.id});
                  showPlayerSnackBar(context, player,
                      ' has 7 days to pack his stuff or change your mind !');
                  _playerStream = _updatePlayerStream();
                } on PostgrestException catch (error) {
                  print(error);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error.code!),
                    ),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _UnFirePlayer(Player player) async {
    try {
      await supabase.from('players').update({
        'date_firing': null // Set date_firing to null to "Unfire" the player
      }).match({'id': player.id});
      showPlayerSnackBar(context, player, ' has been unfired.');
      // Fetch updated data by calling _fetchPlayersStream again
      _playerStream = _updatePlayerStream();
    } on PostgrestException catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.code!),
        ),
      );
    }
  }
}
