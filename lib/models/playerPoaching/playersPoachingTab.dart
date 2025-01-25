import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/widgets/graphWidget.dart';

Widget getPlayersPoachingTab(List<Player> players) {
  return Column(
    children: [
      ListTile(
        leading: Icon(iconPoaching, color: Colors.green, size: iconSizeMedium),
        title: Text('Poached Players',
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
            return ListTile(
              leading: Icon(player.getPlayerIcon(),
                  size: iconSizeMedium, color: Colors.green),
              title: player.getPlayerNameClickable(context),
              subtitle: Column(
                children: [
                  /// Promied expenses

                  InkWell(
                    child: Row(
                      children: [
                        Text('Weekly scouting staff investment: ',
                            style: styleItalicBlueGrey),
                        Text(
                          player.poaching!.investmentTarget.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
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
                        Text('Affinity: ', style: styleItalicBlueGrey),
                        Text(
                          player.poaching!.affinity.last.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    onTap: () async {
                      final chartData = ChartData(
                        title: 'Player affinity to the club',
                        yValues: [player.poaching!.affinity],
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
                        Text('Motivation: ', style: styleItalicBlueGrey),
                        Text(
                          player.motivation.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    // onTap: () async {
                    //   final chartData = ChartData(
                    //     title: 'Player motivation',
                    //     yValues: [player.motivation],
                    //     typeXAxis: XAxisType.weekHistory,
                    //   );

                    //   showDialog(
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return ChartDialogBox(chartData: chartData);
                    //     },
                    //   );
                    // },
                  ),
                ],
              ),
              shape: shapePersoRoundedBorder(),
              trailing: IconButton(
                icon: Icon(iconCancel, color: Colors.red),
                onPressed: () async {
                  bool isOK = await operationInDB(
                      context, 'DELETE', 'players_poaching',
                      matchCriteria: {
                        'id': player.poaching!.id,
                      });
                  if (isOK) {
                    context.showSnackBar(
                        'Successfully removed ${player.getFullName()} from the list of poached players',
                        icon:
                            Icon(iconSuccessfulOperation, color: Colors.green));
                  }
                },
              ),
            );
          },
        ),
      ),
    ],
  );
}
