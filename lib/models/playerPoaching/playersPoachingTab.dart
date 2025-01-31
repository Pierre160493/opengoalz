import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerChartDialogBox.dart';
import 'package:opengoalz/models/playerPoaching/playerPoachingIconButton.dart';
import 'package:opengoalz/models/playerPoaching/player_poaching.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:provider/provider.dart';

Widget getPlayersPoachingTab(List<PlayerPoaching> playersPoached) {
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
            PlayerPoaching playerPoached = playersPoached[index];
            double? diffLastWeekAffinity = playerPoached.lisAffinity.isNotEmpty
                ? playerPoached.affinity - playerPoached.lisAffinity.last
                : null;
            if (playerPoached.player == null) {
              return ListTile(
                leading: Icon(Icons.error, color: Colors.red),
                title: Text('Player not found'),
                subtitle: Text('Player ID: ${playerPoached.idPlayer}'),
                shape: shapePersoRoundedBorder(Colors.red),
              );
            }
            return ListTile(
              leading: Tooltip(
                message: playerPoached.toDelete == true ? 'To delete' : '',
                child: Icon(playerPoached.player!.getPlayerIcon(),
                    size: iconSizeLarge,
                    color: playerPoached.toDelete == true
                        ? Colors.red
                        : Colors.green),
              ),
              title: playerPoached.player!.getPlayerNameClickable(context),
              subtitle: Column(
                children: [
                  /// Weekly scouting staff investment

                  InkWell(
                    child: Row(
                      children: [
                        Icon(iconScouts,
                            color: playerPoached.investmentTarget > 0
                                ? Colors.green
                                : Colors.red),
                        Text(
                          playerPoached.investmentTarget.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(' Weekly scouting staff investment',
                            style: styleItalicBlueGrey),
                      ],
                    ),
                    onTap: () async {
                      final chartData = ChartData(
                        title: 'Weekly scouting staff investment',
                        yValues: [playerPoached.investmentWeekly],
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

                  /// Affinity of the player to the club
                  InkWell(
                    child: Row(
                      children: [
                        Icon(Icons.verified,
                            color: playerPoached.affinity < 10
                                ? Colors.red
                                : playerPoached.affinity < 25
                                    ? Colors.orange
                                    : Colors.green),
                        Text(
                          playerPoached.affinity.toString(),
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
                          [...playerPoached.lisAffinity, playerPoached.affinity]
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

                  /// Player's motivation
                  InkWell(
                    child: Row(
                      children: [
                        Icon(iconMotivation,
                            color: playerPoached.player!.motivation > 50
                                ? Colors.green
                                : playerPoached.player!.motivation > 20
                                    ? Colors.orange
                                    : Colors.red),
                        Text(
                          playerPoached.player!.motivation.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(' Motivation', style: styleItalicBlueGrey),
                      ],
                    ),

                    /// Fetch the data from the database and display it on the graph dialog box
                    onTap: () async {
                      await showHistoryChartDialog(
                        context,
                        playerPoached.player!.id,
                        'motivation',
                        'Player motivation over time',
                        dataToAppend: playerPoached.player!.motivation,
                      );
                    },
                  ),
                ],
              ),
              shape: shapePersoRoundedBorder(),
              trailing: playerSetAsPoachingIconButton(
                  context,
                  playerPoached.player!,
                  Provider.of<UserSessionProvider>(context, listen: false)
                      .user!),
            );
          },
        ),
      ),
    ],
  );
}
