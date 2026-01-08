import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/stats/player_history_timeline.dart';
import 'package:opengoalz/models/player/widgets/player_name_tooltip.dart';

class PlayerHistoryPage extends StatelessWidget {
  final Player player;

  const PlayerHistoryPage({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PlayerNameTooltip(player: player),
          Text(
            ' History',
            style: TextStyle(fontSize: fontSizeLarge),
          ),
        ],
      )),
      body: PlayerHistoryTimeline(
        player: player,
      ),
    );
  }
}
