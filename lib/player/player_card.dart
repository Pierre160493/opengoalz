import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/player/players_page.dart';
import 'package:opengoalz/widgets/transfer_widget.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'class/player.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final int number;

  const PlayerCard({Key? key, required this.player, required this.number})
      : super(key: key);

  @override
  _PlayerCardState createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _developed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      widget.player.keeper,
      widget.player.defense,
      widget.player.playmaking,
      widget.player.passes,
      widget.player.winger,
      widget.player.scoring,
      widget.player.freekick,
    ];
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.number > 0)
                  Text(
                    '${widget.number})',
                    style: TextStyle(
                        color: Colors
                            .white, // Change the color of the text as needed
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle
                            .italic, // Add this line to make the text italic
                        fontSize: 20.0),
                  ),
                const SizedBox(width: 6.0),
                Flexible(
                  child: Text(
                    '${widget.player.first_name[0]}.${widget.player.last_name.toUpperCase()} ',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                widget.player.getStatusRow(),

                /// Spacer widget to push the following widgets to the right
                // Spacer(),

                /// IconButton to expand/collapse the player card
                IconButton(
                  icon: Icon(
                    _developed
                        ? Icons.expand_less
                        : Icons.expand_circle_down_outlined,
                    color: Colors.purple[300], // Set the icon color
                  ),
                  iconSize: 24.0,
                  onPressed: () {
                    setState(() {
                      _developed = !_developed;
                    });
                  },
                ),

                /// PopMenuButton if the player belongs to current user's club
                if (widget.player.id_club ==
                    Provider.of<SessionProvider>(context, listen: false)
                        .selectedClub
                        .id_club)
                  playerPopUpMenuItem(widget.player),
                const SizedBox(width: 6.0),
              ],
            ),
            if (!_developed) widget.player.getPlayerMainInformation(context),
            const SizedBox(height: 6.0),
            if (_developed)
              SizedBox(
                width: double.infinity,
                // height: 400, // Adjust the height as needed
                height: MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    120, // Adjust the height as needed
                child: DefaultTabController(
                  length: 4,
                  child: Scaffold(
                    appBar: TabBar(
                      tabs: [
                        Tab(text: 'Details'),
                        // Tab(text: 'Photo'),
                        Tab(text: 'Stats'),
                        Tab(text: 'Games'),
                        Tab(text: 'History')
                      ],
                    ),
                    body: TabBarView(
                      children: [
                        /// Details tab
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6.0),
                              widget.player.getPlayerMainInformation(context),
                              const SizedBox(height: 6.0),

                              /// Selling tile
                              if (widget.player.date_sell
                                      ?.isAfter(DateTime.now()) ??
                                  false)
                                PlayerTransferTile(
                                  player: widget.player,
                                ), // Show the transfer tile
                              const SizedBox(height: 6),

                              /// Firing tile
                              if (widget.player.date_firing != null)
                                widget.player
                                    .getFiringRow(), // Show the firing row
                              const SizedBox(height: 6),
                              if (widget.player.date_end_injury != null)
                                widget.player
                                    .getInjuryWidget(), // Show the injury tile
                              // widget.player.getUserNameWidget(),
                            ],
                          ),
                        ),

                        /// Stats Tab
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 6.0),
                              widget.player.getStaminaWidget(),
                              const SizedBox(height: 6.0),
                              widget.player.getFormWidget(),
                              const SizedBox(height: 6.0),
                              widget.player.getExperienceWidget(),
                              SizedBox(
                                width: double.infinity,
                                height: 240, // Adjust the height as needed
                                child: RadarChart.dark(
                                  ticks: const [25, 50, 75, 100],
                                  features: const [
                                    'GK',
                                    'DF',
                                    'PA',
                                    'PL',
                                    'WI',
                                    'SC',
                                    'FK',
                                  ],
                                  data: [features],
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 240, // Adjust the height as needed
                                child: RadarChart.dark(
                                  ticks: const [25, 50, 75, 100],
                                  features: const [
                                    'GK',
                                    'DF',
                                    'PA',
                                    'PL',
                                    'WI',
                                    'SC',
                                    'FK',
                                  ],
                                  data: [features],
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Games tab
                        Placeholder(),

                        /// History tab
                        Placeholder(),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget playerPopUpMenuItem(Player player) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (widget.number >
            0) // Show the "Open Page" option only if multiple players currently displayed
          const PopupMenuItem<String>(
            value: 'Open Page',
            child: ListTile(
              leading: Icon(Icons.open_in_new),
              title: Text('Open Player\'s Page'),
            ),
          ),
        if (widget.player.date_sell == null)
          if (widget.player.date_firing == null) ...[
            const PopupMenuItem<String>(
              value: 'Sell',
              child: ListTile(
                leading: Icon(icon_transfers),
                title: Text('Sell'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'Fire',
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Fire'),
              ),
            )
          ] else
            const PopupMenuItem<String>(
              value: 'Unfire',
              child: ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Unfire'),
              ),
            ),
        // Add more PopupMenuItems for additional actions
      ],
      onSelected: (String value) {
        // Handle selected action here
        switch (value) {
          case 'Open Page':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayersPage(
                  inputCriteria: {
                    'Players': [widget.player.id]
                  },
                ),
              ),
            );
            break;
          case 'Sell':
            _SellPlayer(widget.player); // Sell Player
            break;
          case 'Fire':
            _FirePlayer(widget.player); // Fire Player
            break;
          case 'Unfire':
            _UnFirePlayer(widget.player); // Unfire Player
            break;
          // Add cases for additional actions if needed
        }
      },
      child: Icon(
        Icons.pending_actions_outlined,
        color: Colors.purple[300],
      ),
    );
  }

  Future<void> _SellPlayer(Player player) async {
    final TextEditingController _priceController =
        TextEditingController(text: '0'); // Initialize with default value

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Put to transfer list'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the starting price for ${player.first_name} ${player.last_name.toUpperCase()}',
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
                  await supabase.from('transfers_bids').insert({
                    'amount': minimumPrice,
                    'id_player': player.id,
                    'id_club':
                        Provider.of<SessionProvider>(context, listen: false)
                            .selectedClub
                            .id_club,
                  });
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                          '${player.first_name} ${player.last_name.toUpperCase()} has been put to transfer list'),
                    ),
                  );
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                          '${player.first_name} ${player.last_name.toUpperCase()} has 7 days to pack his stuff and leave !'),
                    ),
                  );
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await supabase.from('players').update({
        'date_firing': null // Set date_firing to null to "Unfire" the player
      }).match({'id': player.id});
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
              '${player.first_name} ${player.last_name.toUpperCase()} is happy to stay in your club !'),
        ),
      );
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
