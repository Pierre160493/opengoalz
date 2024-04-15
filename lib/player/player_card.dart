import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/widgets/transfer_widget.dart';

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
                IconButton(
                  icon: Icon(
                    _developed ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white, // Set the icon color
                  ),
                  iconSize: 24.0,
                  onPressed: () {
                    setState(() {
                      _developed = !_developed;
                    });
                  },
                ),
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
                    30, // Adjust the height as needed
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
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text('Defense '),
                                  SizedBox(
                                    width:
                                        200, // Adjust the width of the bar as needed
                                    height: 20, // Height of the bar
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          10), // Rounded corners for the bar
                                      child: LinearProgressIndicator(
                                        value: widget.player.defense /
                                            100, // Assuming widget.player.defense ranges from 0 to 100
                                        backgroundColor: Colors.grey[
                                            300], // Background color of the bar
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors
                                                .blue), // Color of the filled portion of the bar
                                      ),
                                    ),
                                  ),
                                ],
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
}
