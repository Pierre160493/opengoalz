import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/player.dart';
import 'package:opengoalz/global_variable.dart';
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

class _PlayerPageState extends State<PlayerPage> {
  Stream<List<Player>> _playerStream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    _playerStream = _fetchPlayersStream(widget.idPlayer);
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
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  try {
                    int? minimumPrice = int.tryParse(_priceController.text);
                    if (minimumPrice == null || minimumPrice < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please enter a valid number for minimum price (should be a positive integer)'),
                        ),
                      );
                      return;
                    }
                    DateTime dateSell =
                        DateTime.now().add(const Duration(days: 7));
                    await supabase.from('players').update({
                      'date_sell': dateSell.toIso8601String()
                    }).match({'id': player.id});
                    await supabase.from('transfers_bids').insert({
                      'amount': minimumPrice,
                      'id_player': player.id,
                    });
                    // showPlayerSnackBar(
                    //     context, player, 'will be put in auction for 7 days !');
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

  // Future<void> _BidPlayer(Player player, int idClubBidder) async {
  Future<void> _BidPlayer(Player player) async {
    // Checks
    if (player.date_sell == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'ERROR: Player ${player.first_name} ${player.last_name.toUpperCase()} doesn\'t seem to be for sale'),
        ),
      );
      return;
    } else if (DateTime.now().isAfter(player.date_sell!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Player ${player.first_name} ${player.last_name.toUpperCase()} transfer\'s deadline is reached, bidding is over... '),
        ),
      );
      return;
    }

    var date_sell = DateTime.now()
        .add(const Duration(minutes: 5)); // Calculate the new date_sell

    final TextEditingController _priceController = TextEditingController(
        text: (player.amount_last_transfer_bid! +
                max(1000, player.amount_last_transfer_bid! * 0.1))
            .toString()); // Initialize with current bid + offset

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
                'What\'s the value of the bid you want to place on ${player.first_name} ${player.last_name.toUpperCase()} ?',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Minimum Bid',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                try {
                  int? newBid = int.tryParse(_priceController.text);
                  if (newBid == null || newBid < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Please enter a valid number for minimum price (should be greater or equal to ${_priceController})'),
                      ),
                    );
                    return;
                  }
                  await supabase.from('transfers_bids').insert({
                    'amount': newBid,
                    'id_player': player.id,
                    'id_club': Provider.of<SessionProvider>(context)
                        .selectedClub
                        .id_club
                  });

                  if (date_sell.isAfter(player.date_sell!)) {
                    await supabase.from('players').update({
                      'date_sell': date_sell.toIso8601String()
                    }).match({'id': player.id});
                  }
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

  Future<void> _FirePlayer(Player player) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text(
              'Are you sure you want to fire ${player.first_name} ${player.last_name.toUpperCase()} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
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
                  print('PG: Seems OK');
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
                appBar: _buildAppBar(players[0]),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return _buildPlayerCard(player);
                        },
                      ),
                    )
                  ],
                ),
                floatingActionButton: _buildFloatingActionButton(players[0]));
          }
        }
      },
    );
  }

  PreferredSizeWidget _buildAppBar(Player player) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        title: Row(
          children: [
            Text(
              '${player.first_name[0]}.${player.last_name.toUpperCase()} ',
            ),
            if (player.date_sell != null)
              const Icon(
                icon_transfers,
                color: Colors.green,
                size: 30,
              ),
            if (player.date_firing != null)
              const Icon(
                Icons.exit_to_app,
                color: Colors.red,
                size: 30,
              ),
            if (player.date_end_injury != null)
              const Icon(
                icon_medics,
                color: Colors.red,
                size: 30,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Player player) {
    final List<String> smileys = ['😊', '😁', '😄', '😃', '😆', '😅'];
    final String selectedSmiley = smileys[Random().nextInt(smileys.length)];

    final features = [
      player.keeper,
      player.defense,
      player.playmaking,
      player.passes,
      player.winger,
      player.scoring,
      player.freekick,
    ];

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player's name row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text(
                    selectedSmiley,
                    style: const TextStyle(fontSize: 24),
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      24), // Set borderRadius for the outer container
                  border: Border.all(color: Colors.blueGrey),
                ),
                child: ExpansionTile(
                  // Add your onTap logic here if needed
                  // onTap: () {},

                  leading: Icon(
                    icon_transfers,
                    size: 36,
                    color: Colors.green,
                  ),
                  title: Row(
                    children: [
                      Text(
                        player.id_club_last_transfer_bid != null
                            ? 'Current Bid by ${player.name_club_last_transfer_bid}'
                            : 'Asking Price: ',
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blueGrey,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          player.amount_last_transfer_bid.toString(),
                        ),
                      ),
                      if (player.id_club !=
                          Provider.of<SessionProvider>(context)
                              .selectedClub
                              .id_club)
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_circle_up_outlined,
                            size: 24,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            _BidPlayer(player
                                //,
                                // Provider.of<SessionProvider>(context)
                                //     .selectedClub
                                //     .id_club
                                );
                          },
                        ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      StreamBuilder<int>(
                        stream: Stream.periodic(
                            const Duration(seconds: 1), (i) => i),
                        builder: (context, snapshot) {
                          final remainingTime =
                              player.date_sell!.difference(DateTime.now());
                          final daysLeft = remainingTime.inDays;
                          final hoursLeft = remainingTime.inHours.remainder(24);
                          final minutesLeft =
                              remainingTime.inMinutes.remainder(60);
                          final secondsLeft =
                              remainingTime.inSeconds.remainder(60);

                          return RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${DateFormat('EEE d HH:mm', 'en_US').format(player.date_sell!)} in: ',
                                  style: TextStyle(),
                                ),
                                if (daysLeft > 0)
                                  TextSpan(
                                    text: '${daysLeft}d, ',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                TextSpan(
                                  text:
                                      '${hoursLeft}h${minutesLeft}m${secondsLeft}s',
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
                  // Additional information to be displayed when the tile is expanded
                  children: <Widget>[
                    // Add your additional widgets here
                    // For example:
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Additional information"),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            if (player.date_firing != null)
              Row(
                children: [
                  StreamBuilder<int>(
                    stream:
                        Stream.periodic(const Duration(seconds: 1), (i) => i),
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
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Still injured for: ',
                      style: const TextStyle(),
                      children: [
                        TextSpan(
                          text:
                              ' ${player.date_end_injury!.difference(DateTime.now()).inDays.toString()} days',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold, // Remove bold font weight
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Age: ',
                    children: [
                      TextSpan(
                        text: player.age.toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold, // Remove bold font weight
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Club: ',
                    children: [
                      TextSpan(
                        text: player.club_name,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold, // Remove bold font weight
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 24), // Add spacing between name and radar chart
            SizedBox(
              width: double.infinity, // Make radar chart fill available width
              height: 240, // Adjust this value as needed
              child: RadarChart.dark(
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
}
