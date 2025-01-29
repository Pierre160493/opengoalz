import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerChartDialogBox.dart';
import 'package:opengoalz/models/playerPoaching/playerPoachingIconButton.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:provider/provider.dart';

Widget getPlayersPoachingTab(List<Player> players) {
  return Column(
    children: [
      ListTile(
        leading: Icon(iconPoaching, color: Colors.green, size: iconSizeMedium),
        title: Text('${players.length} Poached Players',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('List of players your scouting network are working on',
            style: styleItalicBlueGrey),
        shape: shapePersoRoundedBorder(Colors.green, 3),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            double? diffLastWeekAffinity = player
                    .poaching!.lisAffinity.isNotEmpty
                ? player.poaching!.affinity - player.poaching!.lisAffinity.last
                : null;
            return ListTile(
              leading: Tooltip(
                message: player.poaching!.toDelete == true ? 'To delete' : '',
                child: Icon(player.getPlayerIcon(),
                    size: iconSizeLarge,
                    color: player.poaching!.toDelete == true
                        ? Colors.red
                        : Colors.green),
              ),
              title: player.getPlayerNameClickable(context),
              subtitle: Column(
                children: [
                  /// Weekly scouting staff investment

                  InkWell(
                    child: Row(
                      children: [
                        Icon(iconScouts,
                            color: player.poaching!.investmentTarget > 0
                                ? Colors.green
                                : Colors.red),
                        Text(
                          player.poaching!.investmentTarget.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(' Weekly scouting staff investment',
                            style: styleItalicBlueGrey),
                      ],
                    ),
                    onTap: () async {
                      final chartData = ChartData(
                        title: 'Weekly scouting staff investment',
                        yValues: [player.poaching!.investmentWeekly],
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
                            color: player.poaching!.affinity < 10
                                ? Colors.red
                                : player.poaching!.affinity < 25
                                    ? Colors.orange
                                    : Colors.green),
                        Text(
                          player.poaching!.affinity.toString(),
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
                          [
                            ...player.poaching!.lisAffinity,
                            player.poaching!.affinity
                          ]
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

                    /// Fetch the data from the database and display it on the graph dialog box
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
              trailing: playerSetAsPoachingIconButton(context, player,
                  Provider.of<SessionProvider>(context, listen: false).user!),
            );
          },
        ),
      ),
    ],
  );
}
