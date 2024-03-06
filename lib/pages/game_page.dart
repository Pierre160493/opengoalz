import 'package:flutter/material.dart';
import 'package:opengoalz/widgets/appBar.dart';
import 'package:opengoalz/widgets/appDrawer.dart';

import '../classes/game.dart';
import '../constants.dart';

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
        title: Text('${game.nameClubLeft} vs ${game.nameClubRight}'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.access_time), // Add clock icon
            title: const Text('Date'),
            subtitle: Text('${game.dateStart}'),
          ),
          ListTile(
            title: const Text('Week Number'),
            subtitle: Text('${game.weekNumber}'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Left Club'),
            subtitle: Text('${game.nameClubLeft}'),
          ),
          ListTile(
            title: const Text('Right Club'),
            subtitle: Text('${game.nameClubRight}'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Stadium ID'),
            subtitle: Text('${game.idStadium}'),
          ),
          ListTile(
            title: const Text('Is Played'),
            subtitle: Text('${game.isPlayed ? 'Yes' : 'No'}'),
          ),
          ListTile(
            title: const Text('Is Cup'),
            subtitle: Text('${game.isCup ? 'Yes' : 'No'}'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Goals Left'),
            subtitle: Text('${game.goalsLeft}'),
          ),
          ListTile(
            title: const Text('Goals Right'),
            subtitle: Text('${game.goalsRight}'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Left Club User'),
            subtitle: Text('${game.usernameClubLeft}'),
          ),
          ListTile(
            title: const Text('Right Club User'),
            subtitle: Text('${game.usernameClubRight}'),
          ),
        ],
      ),
    );
  }
}
