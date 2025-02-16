import 'package:flutter/material.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/functions/positionString.dart';

Widget getGameIcon(BuildContext context, Game game) {
  // Icon of the game: cup, league, friendly, relegation or stars of the selected player

  if (game.gamePlayerStatsBest != null) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.star,
              size: 60,
              color: Colors.yellow,
            ),
            Positioned(
              top: 10,
              child: Text(
                game.gamePlayerStatsBest!.stars.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        Tooltip(
          message: getPositionText(game.gamePlayerStatsBest!.position,
              shortText: false),
          child: Text(
            getPositionText(game.gamePlayerStatsBest!.position),
            style: TextStyle(
              color: Colors.blueGrey,
            ),
          ),
        ),
      ],
    );
  }

  // Default game icon
  Icon mainIcon = Icon(
    game.isRelegation
        ? Icons.expand
        : game.isFriendly
            ? Icons.handshake
            : Icons.emoji_events_outlined,
    size: 60,
    color: Colors.yellow,
  );

  // Text under the icon
  Text text = Text(
    game.weekNumber < 11
        ? ' ${game.weekNumber}/10'
        : ' Inter ${game.weekNumber - 10}',
    style: TextStyle(
      color: Colors.blueGrey,
    ),
  );

  Icon programIcon = Icon(
    game.weekNumber < 11
        ? Icons.calendar_month_outlined
        : Icons.format_list_bulleted_add,
    color: Colors.blueGrey,
  );

  return Column(children: [
    mainIcon,
    Row(
      children: [
        programIcon,
        text,
      ],
    )
  ]);
}
