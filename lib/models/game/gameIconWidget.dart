import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/functions/positionString.dart';
import 'package:opengoalz/models/game/gamePlayerStatsDialog.dart';
import 'package:opengoalz/models/playerStatsBest.dart';

Widget getGameIcon(BuildContext context, Game game) {
  /// If this is the game for a given player, display his best stars obtained in the game
  if (game.playerGameBestStats != null &&
      game.playerGameBestStats!.gamePlayerStatsBest != null) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => buildPlayerStatsDialog(context, game),
            );
          },
          child: buildStarIcon(
              game.playerGameBestStats!.gamePlayerStatsBest!.stars, 60),
        ),
        Tooltip(
          message: getPositionText(
              game.playerGameBestStats!.gamePlayerStatsBest!.position,
              shortText: false),
          child: Text(
            getPositionText(
                game.playerGameBestStats!.gamePlayerStatsBest!.position),
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
    size: 2 * iconSizeLarge,
    color: Colors.yellow,
  );

  // Text under the icon
  Text text = Text(
    game.weekNumber < 11
        ? ' ${game.weekNumber}/10'
        : ' Inter ${game.weekNumber - 10}',
    style: TextStyle(
      fontSize: fontSizeMedium,
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
