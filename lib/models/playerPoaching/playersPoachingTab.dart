import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerChartDialogBox.dart';
import 'package:opengoalz/models/playerPoaching/playerPoachingIconButton.dart';
import 'package:opengoalz/models/playerPoaching/player_poaching.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/widgets/graphWidget.dart';

Widget getPlayersPoachingTab(List<Player> playersPoached, Profile user) {
  if (playersPoached.isEmpty) {
    return Center(
      child: Text('No poached players'),
    );
  }
  return Column(
    children: [
      ListTile(
        leading: Icon(iconPoaching, color: Colors.green, size: iconSizeMedium),
        title: Text('${playersPoached.length} Poached Players',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('List of players your scouting network are working on',
            style: styleItalicBlueGrey),
        shape: shapePersoRoundedBorder(Colors.green, 3),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: playersPoached.length,
          itemBuilder: (context, index) {
            Player player = playersPoached[index];
            return buildPlayerPoachingTile(context, player, user);
            // return Text('test');
          },
        ),
      ),
    ],
  );
}

Widget buildPlayerPoachingTile(
    BuildContext context, Player player, Profile user) {
  if (player.poaching == null) {
    return ListTile(
      leading: Icon(Icons.error, color: Colors.red),
      title: Text('Player not found'),
      subtitle: Text('Player ID: ${player.id}'),
      shape: shapePersoRoundedBorder(Colors.red),
    );
  }
  PlayerPoaching playerPoaching = player.poaching!;
  double? diffLastWeekAffinity = playerPoaching.lisAffinity.isNotEmpty
      ? playerPoaching.affinity - playerPoaching.lisAffinity.last
      : null;
  return ListTile(
    leading: Tooltip(
      message: playerPoaching.toDelete == true ? 'To delete' : '',
      child: Icon(player.getPlayerIcon(),
          size: iconSizeLarge,
          color: playerPoaching.toDelete == true ? Colors.red : Colors.green),
    ),
    title: player.getPlayerNameClickable(context),
    subtitle: Column(
      children: [
        // Weekly scouting staff investment
        InkWell(
          child: Row(
            children: [
              Icon(iconScouts,
                  color: playerPoaching.investmentTarget > 0
                      ? Colors.green
                      : Colors.red),
              Text(
                playerPoaching.investmentTarget.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(' Weekly scouting staff investment',
                  style: styleItalicBlueGrey),
            ],
          ),
          onTap: () async {
            final chartData = ChartData(
              title: 'Weekly scouting staff investment',
              yValues: [playerPoaching.investmentWeekly],
              typeXAxis: XAxisType.weekHistory,
            );

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ChartDialogBox(chartData: chartData);
              },
            );
          },
        ),
        // Affinity of the player to the club
        InkWell(
          child: Row(
            children: [
              Icon(Icons.verified,
                  color: playerPoaching.affinity < 10
                      ? Colors.red
                      : playerPoaching.affinity < 25
                          ? Colors.orange
                          : Colors.green),
              Text(
                playerPoaching.affinity.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(' Club Affinity', style: styleItalicBlueGrey),
              if (diffLastWeekAffinity != null)
                Tooltip(
                  message: 'Compared to last week',
                  child: Text(
                    ' (${diffLastWeekAffinity < 0 ? '' : '+'}${diffLastWeekAffinity.toStringAsFixed(2)})',
                    style: TextStyle(
                        color: diffLastWeekAffinity < 0
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          onTap: () async {
            final chartData = ChartData(
              title: 'Player affinity to the club',
              yValues: [
                [...playerPoaching.lisAffinity, playerPoaching.affinity]
              ],
              typeXAxis: XAxisType.weekHistory,
            );

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ChartDialogBox(chartData: chartData);
              },
            );
          },
        ),
        // Player's motivation
        InkWell(
          child: Row(
            children: [
              Icon(iconMotivation,
                  color: player.motivation > 50
                      ? Colors.green
                      : player.motivation > 20
                          ? Colors.orange
                          : Colors.red),
              Text(
                player.motivation.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(' Motivation', style: styleItalicBlueGrey),
            ],
          ),
          onTap: () async {
            await showHistoryChartDialog(
              context,
              player.id,
              'motivation',
              'Player motivation over time',
              dataToAppend: player.motivation,
            );
          },
        ),
      ],
    ),
    shape: shapePersoRoundedBorder(),
    trailing: PlayerPoachingIconButton(player: player, user: user),
  );
}
