import 'package:flutter/material.dart';
import 'package:opengoalz/classes/event.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/player/class/player.dart';
import 'package:rxdart/rxdart.dart';

import '../classes/game.dart';

class GamePage extends StatefulWidget {
  final Game game;
  const GamePage({Key? key, required this.game}) : super(key: key);

  static Route<void> route(Game game) {
    return MaterialPageRoute(
      builder: (context) => GamePage(game: game),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<GamePage> {
  late Stream<List<GameEvent>> _eventStream;
  late Stream<List<Player>> _playerStream;

  @override
  void initState() {
    _eventStream = supabase
        .from('game_events')
        .stream(primaryKey: ['id'])
        .eq('id_game', widget.game.id)
        .order('date_event', ascending: true)
        .map((maps) => maps.map((map) => GameEvent.fromMap(map)).toList());

    _playerStream = _eventStream.switchMap((event) {
      final playerIds = event.map((event) => event.id_player).toSet().toList();
      return supabase
          .from('players')
          .stream(primaryKey: ['id'])
          .inFilter('id', playerIds.cast<Object>())
          .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
    });

    _eventStream =
        _eventStream.switchMap((events) => _playerStream.map((players) {
              for (var event in events) {
                final playerData = players
                    .firstWhere((player) => player.id == event.id_player);
                event.player = playerData;
              }
              return events;
            }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GameEvent>>(
        stream: _eventStream,
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
            // final players = snapshot.data ?? [];
            final List<GameEvent> events = (snapshot.data ?? []);

            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          ClubPage.route(widget.game.idClubLeft),
                        );
                      },
                      child: widget.game.getLeftClubName(),
                    ),
                    SizedBox(width: 6),
                    widget.game.isPlayed
                        ? widget.game.getScoreRow()
                        : Text('VS'),
                    SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          ClubPage.route(widget.game.idClubRight),
                        );
                      },
                      child: widget.game.getRightClubName(),
                    ),
                  ],
                ),
              ),
              body: DefaultTabController(
                  length: 3, // Number of tabs
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Details'),
                          Tab(text: 'Report'),
                          Tab(text: 'Teams'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            widget.game.getGameDetail(context),
                            _getGameReport(events, context),
                            // _getTeamsComp(events, context),
                            Text('test'),
                          ],
                        ),
                      ),
                    ],
                  )),
            );
          }
        });
  }

  Widget _getGameReport(List<GameEvent> events, BuildContext context) {
    int leftClubScore = 0;
    int rightClubScore = 0;

    if (events.length == 0) return Text('No events found');

    return Column(
      children: [
        SizedBox(
          height: 12,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          SizedBox(),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                ClubPage.route(widget.game.idClubLeft),
              );
            },
            child: Row(
              children: [
                Icon(Icons.home),
                SizedBox(
                  width: 12,
                ),
                Text(
                  widget.game.nameClubLeft,
                  style:
                      TextStyle(fontSize: 24), // Increase the font size to 20
                ),
              ],
            ),
          ),
          Icon(
            Icons.compare_arrows,
            size: 30,
            color: Colors.green,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                ClubPage.route(widget.game.idClubRight),
              );
            },
            child: Row(
              children: [
                Text(
                  widget.game.nameClubRight,
                  style:
                      TextStyle(fontSize: 24), // Increase the font size to 20
                ),
                SizedBox(
                  width: 12,
                ),
                Icon(Icons.home),
              ],
            ),
          ),
          // SizedBox(),
        ]),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              if (index == 0) {
                leftClubScore = 0;
                rightClubScore = 0;
              }

              // Update scores based on event type (assuming event type 1 is a goal)
              if (event.idEventType == 1) {
                if (event.id_club == widget.game.idClubLeft) {
                  leftClubScore++;
                } else if (event.id_club == widget.game.idClubRight) {
                  rightClubScore++;
                }
              }

              return ListTile(
                leading: Container(
                  width: 100, // Fixed width to ensure alignment
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueGrey,
                        ),
                        child: Center(
                          child: Text(
                            '${event.gameMinute.toString()}\'',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      if (event.idEventType == 1) // Conditionally display score
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$leftClubScore - $rightClubScore',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                title: Row(
                  children: [
                    event.id_club == widget.game.idClubRight
                        ? Spacer()
                        : SizedBox(width: 6),
                    event.getDescription(context),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getTeamsComp(List<GameEvent> events, BuildContext context) {
    int leftClubScore = 0;
    int rightClubScore = 0;
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        // Update scores based on event type (assuming event type 1 is a goal)
        if (event.idEventType == 1) {
          if (event.id_club == widget.game.idClubLeft) {
            leftClubScore++;
          } else if (event.id_club == widget.game.idClubRight) {
            rightClubScore++;
          }
        }

        return ListTile(
          leading: Container(
            width: 100, // Fixed width to ensure alignment
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueGrey,
                  ),
                  child: Center(
                    child: Text(
                      '${event.gameMinute.toString()}\'',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                if (event.idEventType == 1) // Conditionally display score
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$leftClubScore - $rightClubScore',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          title: Row(
            children: [
              event.id_club == widget.game.idClubRight
                  ? Spacer()
                  : SizedBox(width: 6),
              // Icon(Icons.home_filled, color: Colors.blueGrey),
              event.id_club == widget.game.idClubLeft
                  ? widget.game.getLeftClubName()
                  : widget.game.getRightClubName(),
            ],
          ),
          subtitle: Row(
            children: [
              event.id_club == widget.game.idClubRight
                  ? Spacer()
                  : SizedBox(width: 6),
              event.getDescription(context),
            ],
          ),
        );
      },
    );
  }
}
