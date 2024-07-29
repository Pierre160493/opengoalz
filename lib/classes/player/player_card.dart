import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/provider_global_variable.dart';
import 'package:provider/provider.dart';
import 'class/player.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final int number;
  final bool isExpanded;

  const PlayerCard(
      {Key? key,
      required this.player,
      required this.number,
      this.isExpanded = false})
      : super(key: key);

  @override
  _PlayerCardState createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Stream<List<Map>> _historyStream;
  bool _developed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _developed = widget.isExpanded;

    _historyStream = supabase
        .from('players_history')
        .stream(primaryKey: ['id'])
        .eq('id_player', widget.player.id)
        .order('created_at', ascending: false)
        .map((maps) => maps
            .map((map) => {
                  'id': map['id'],
                  'created_at': map['created_at'],
                  'id_player': map['id_player'],
                  'description': map['description'],
                  'id_club': map['id_club'],
                })
            .toList());
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
                    '${widget.player.firstName[0]}.${widget.player.lastName.toUpperCase()} ',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
                widget.player.getStatusRow(),

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
                if (widget.player.idClub ==
                    Provider.of<SessionProvider>(context, listen: false)
                        .user!
                        .selectedClub
                        .id)
                  widget.player.playerPopUpMenuItem(context, widget.number)
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
                            ],
                          ),
                        ),

                        /// Stats Tab
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 6.0),
                              widget.player.getStatLinearWidget(
                                  'Stamina', widget.player.stamina),
                              const SizedBox(height: 6.0),
                              widget.player.getStatLinearWidget(
                                  'Form', widget.player.form),
                              const SizedBox(height: 6.0),
                              widget.player.getStatLinearWidget(
                                  'Experience', widget.player.experience),
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
                              // SizedBox(
                              //   width: double.infinity,
                              //   height: 240, // Adjust the height as needed
                              //   child: RadarChart.dark(
                              //     ticks: const [25, 50, 75, 100],
                              //     features: const [
                              //       'GK',
                              //       'DF',
                              //       'PA',
                              //       'PL',
                              //       'WI',
                              //       'SC',
                              //       'FK',
                              //     ],
                              //     data: [features],
                              //   ),
                              // ),
                            ],
                          ),
                        ),

                        /// Games tab
                        Placeholder(),

                        /// History tab
                        // Placeholder(),

                        StreamBuilder<List<Map>>(
                          stream: _historyStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              // Extract history data from snapshot
                              final historyData = snapshot.data!;
                              return SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: historyData.length,
                                      itemBuilder: (context, index) {
                                        final item = historyData[index];
                                        final DateTime dateEvent =
                                            DateTime.parse(item['created_at']);
                                        final double ageEvent = dateEvent
                                                .difference(
                                                    widget.player.dateBirth)
                                                .inDays /
                                            112.0;
                                        return ListTile(
                                          title: Text(
                                            item['description'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Icon(
                                                Icons.cake_outlined,
                                                color: Colors.green,
                                              ),
                                              Text(
                                                ' ${ageEvent.truncate()}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(' years, '),
                                              Text(
                                                ((ageEvent -
                                                            ageEvent
                                                                .truncate()) *
                                                        112)
                                                    .floor()
                                                    .toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(' days '),
                                              Icon(Icons.access_time_outlined,
                                                  color: Colors.green),
                                              Text(
                                                '${DateFormat(' yyyy-MM-dd HH:mm').format(dateEvent)}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          leading: Icon(
                                            Icons.history_edu_outlined,
                                            color: Colors.blueGrey,
                                            size: 36,
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.grey[400],
                                          ),
                                          onTap: () {
                                            // Add any action you want to perform when the tile is tapped
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            // By default, show a loading indicator
                            return CircularProgressIndicator();
                          },
                        ),
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
