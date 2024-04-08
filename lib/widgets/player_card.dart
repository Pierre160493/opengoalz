import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:opengoalz/pages/club_page.dart';

import '../classes/player/player.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final int? number;

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
                if (widget.number != null)
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
                    overflow: TextOverflow
                        .ellipsis, // Handles overflow by displaying "..."
                    maxLines: 1, // Limits to one line
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
            if (!_developed)
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          child: Icon(
                            Icons.person_pin_outlined,
                            size: 90,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ), // Add some space between the avatar and the text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.player.getAgeWidget(),
                            // getCountryNameWidget(widget.player.id_country),
                            widget.player.getAvgStatsWidget(),
                            // getCountryNameWidget(widget.player.id_country),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 6.0),
            if (_developed)
              SizedBox(
                width: double.infinity,
                height: 360, // Adjust the height as needed
                child: DefaultTabController(
                  length: 4,
                  child: Scaffold(
                    appBar: TabBar(
                      tabs: [
                        Tab(text: 'Details'),
                        Tab(text: 'Stats'),
                        Tab(text: 'Games'),
                        Tab(text: 'History'),
                      ],
                    ),
                    body: TabBarView(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Selling tile
                            if (widget.player.date_sell != null)
                              Text(widget.player.date_sell.toString()),
                            // PlayerTransferTile(
                            //   player: widget.player,
                            //   // onBidCompleted:
                            //   //     refreshView
                            // ), // Show the transfer tile
                            const SizedBox(height: 6),

                            /// Firing tile
                            if (widget.player.date_firing != null)
                              Row(
                                children: [
                                  StreamBuilder<int>(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 1), (i) => i),
                                    builder: (context, snapshot) {
                                      final remainingTime = widget
                                          .player.date_firing!
                                          .difference(DateTime.now());
                                      final daysLeft = remainingTime.inDays;
                                      final hoursLeft =
                                          remainingTime.inHours.remainder(24);
                                      final minutesLeft =
                                          remainingTime.inMinutes.remainder(60);
                                      final secondsLeft =
                                          remainingTime.inSeconds.remainder(60);

                                      return RichText(
                                        text: TextSpan(
                                          text: 'Will be fired in: ',
                                          style: const TextStyle(),
                                          children: [
                                            if (daysLeft >
                                                0) // Conditionally include days left
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
                            if (widget.player.date_end_injury != null)
                              widget.player
                                  .getInjuryWidget(), // Show the injury tile
                            widget.player.getAgeWidget(),
                            GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   ClubPage.route(widget.player.id_club),
                                // );
                              },
                              child: widget.player
                                  .getClubNameWidget(), // Display the ClubWidget
                            ),
                            widget.player.getUserNameWidget(),
                            // widget.player.getCountryNameWidget(),
                            widget.player.getAvgStatsWidget(),
                          ],
                        ),
                        SizedBox(
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
                        Placeholder(),
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
