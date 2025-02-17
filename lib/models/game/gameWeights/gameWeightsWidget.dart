import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/game/gamePlayerStatsAll.dart';
import 'dart:math';

import 'package:opengoalz/widgets/graphWidget.dart';

Widget getGameWeights(BuildContext context, Game game) {
  return FutureBuilder<List<GamePlayerStatsAll>>(
    future: supabase
        .from('game_player_stats_all')
        .select()
        .eq('id_player',
            game.playerGameBestStats!.gamePlayerStatsBest!.idPlayer)
        .eq('id_game', game.id)
        .then((maps) =>
            maps.map((map) => GamePlayerStatsAll.fromMap(map)).toList()),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return loadingCircularAndText('Loading game player stats');
      }
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      if (!snapshot.hasData) {
        return Text('No data available');
      }

      final gamePlayerStatsAll = snapshot.data!;
      game.playerGameBestStats!.gamePlayerStatsAll = gamePlayerStatsAll;

      return SingleChildScrollView(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth * 0.5;
              double height = width * (111 / 74); // Maintain the aspect ratio

              return Container(
                width: width, // Set the width to the available width
                height: height, // Maintain the aspect ratio
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/images/Football_field.svg', // Replace with your SVG file path
                      width: width, // Take up all available width
                      height: height, // Maintain aspect ratio
                      fit: BoxFit.cover,
                    ),
                    for (int i = 1; i <= 7; i++)
                      buildPositionedText(context, i, game, width, height),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

Widget buildPositionedText(BuildContext context, int weightIndex, Game game,
    double width, double height) {
  final weights = game.playerGameBestStats!.gamePlayerStatsBest!.weights;
  final positions = [
    {
      'top': 0.75 * height,
      'left': 0.1 * width,
      'tooltip': 'Left Defense',
      'text': weights.leftDefense.toString()
    },
    {
      'top': 0.75 * height,
      'left': 0.4 * width,
      'tooltip': 'Central Defense',
      'text': weights.centralDefense.toString()
    },
    {
      'top': 0.75 * height,
      'left': 0.9 * width,
      'tooltip': 'Right Defense',
      'text': weights.rightDefense.toString()
    },
    {
      'top': 0.5 * height,
      'left': 0.4 * width,
      'tooltip': 'Midfield',
      'text': weights.midfield.toString()
    },
    {
      'top': 0.25 * height,
      'left': 0.1 * width,
      'tooltip': 'Left Attack',
      'text': weights.leftAttack.toString()
    },
    {
      'top': 0.25 * height,
      'left': 0.4 * width,
      'tooltip': 'Central Attack',
      'text': weights.centralAttack.toString()
    },
    {
      'top': 0.25 * height,
      'left': 0.9 * width,
      'tooltip': 'Right Attack',
      'text': weights.rightAttack.toString()
    },
  ];

  final positionData = positions[weightIndex - 1];
  double fontSize = width * 0.06; // Adjust the font size based on the width

  return Positioned(
    top: positionData['top'] as double,
    left: positionData['left'] as double,
    child: InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final chartData = ChartData(
              title: positionData['tooltip'] as String,
              yValues: [
                game.playerGameBestStats!.gamePlayerStatsAll!
                    .map((e) => e.weights[weightIndex - 1])
                    .toList()
              ],
              typeXAxis: XAxisType.gameMinute,
            );

            return ChartDialogBox(chartData: chartData);
          },
        );
      },
      child: Transform.rotate(
        angle: -30 * pi / 180, // Rotate the text
        child: Tooltip(
            message: positionData['tooltip'] as String?,
            child: Text(positionData['text'] as String,
                style: TextStyle(color: Colors.black, fontSize: fontSize))),
      ),
    ),
  );
}
