import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerCard_Main.dart';

getPlayersWidget(BuildContext context, List<Player> players) {
  if (players.isEmpty) {
    return const Center(
      child: Text('No players found in the list of favorite players'),
    );
  }
  return ListView.builder(
    itemCount: players.length,
    itemBuilder: (context, index) {
      Player player = players[index];
      return PlayerCard(player: player, index: index + 1, isExpanded: false);
    },
  );
}
