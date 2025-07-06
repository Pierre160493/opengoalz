import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/stats/player_history_timeline.dart';

class PlayerHistoryPage extends StatelessWidget {
  final Player player;

  const PlayerHistoryPage({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            player.getPlayerNameToolTip(context),
            Text(' History'),
          ],
        ),
      ),
      body: PlayerHistoryTimeline(
        player: player,
      ),
    );
  }
}
