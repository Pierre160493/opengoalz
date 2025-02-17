import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/positionString.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/game/gameWeights/gameWeightsWidget.dart';

Widget buildPlayerStatsDialog(BuildContext context, Game game) {
  return AlertDialog(
    title: Text(
        'Player Stats playing as: ${getPositionText(game.playerGameBestStats!.gamePlayerStatsBest!.position, shortText: false)}'),
    content: Container(
      width: min(double.infinity, maxWidth),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            getGameWeights(context, game),
          ],
        ),
      ),
    ),
  );
}
