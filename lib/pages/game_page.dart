import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/club_page.dart';

import '../classes/game.dart';

class GamePage extends StatelessWidget {
  final Game game;
  const GamePage({Key? key, required this.game}) : super(key: key);

  static Route<void> route(Game game) {
    return MaterialPageRoute(
      builder: (context) => GamePage(game: game),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  ClubPage.route(game.idClubLeft),
                );
              },
              child: game.getLeftClubName(),
            ),
            SizedBox(width: 6),
            game.isPlayed ? game.getScoreRow() : Text('VS'),
            SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  ClubPage.route(game.idClubRight),
                );
              },
              child: game.getRightClubName(),
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: 600), // Set your desired maximum width
          child: DefaultTabController(
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
                        game.getGameDetail(context),
                        _getGameReport(),
                        game.getDateRow(),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _getGameReport() {
    Stream<List<Map>> gameEventsStream = supabase
        .from('game_events')
        .stream(primaryKey: ['id'])
        .eq('id_game', game.id)
        .order('date_event', ascending: true);
    return StreamBuilder<List<Map>>(
      stream: gameEventsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final List<Map> events = snapshot.data ?? [];
          if (events.isEmpty) {
            return Center(
              child: Text('No events found'),
            );
          } else {
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: Center(
                      child: Text(
                        '${event['game_minute'].toString()}\'',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.home_filled, color: Colors.blueGrey),
                      event['id_club'] == game.idClubLeft
                          ? game.getLeftClubName()
                          : game.getRightClubName(),
                    ],
                  ),
                  subtitle: (() {
                    switch (event['id_event_type']) {
                      case 1:
                        return Row(
                          children: [
                            Icon(Icons.sports_soccer_rounded,
                                color: Colors.green),
                            Text(' Goal by ${event['id_player']}'),
                          ],
                        );
                      case 2:
                        return Row(
                          children: [
                            Text('Assist by ${event['id_player']}'),
                          ],
                        );
                      case 3:
                        return Row(
                          children: [
                            Text('Yellow card for ${event['id_player']}'),
                          ],
                        );
                      case 4:
                        return Row(
                          children: [
                            Icon(Icons.local_fire_department,
                                color: Colors.red),
                            Text('Close shot from ${event['id_player']}'),
                          ],
                        );
                      default:
                        return Text('Unknown event type');
                    }
                  })(),
                );
              },
            );
          }
        }
      },
    );
  }
}
