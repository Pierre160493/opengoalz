import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/events/event.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/game/scoreWidget.dart';
import 'package:opengoalz/functions/stringParser.dart';

Widget buildListOfEvents(BuildContext context, List<GameEvent> events,
    Game game, bool initialExpanded) {
  int leftClubScore = 0;
  int rightClubScore = 0;
  return Expanded(
    child: ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        // Update scores based on event type (assuming event type 1 is a goal)
        if (event.eventType.toUpperCase() == 'GOAL') {
          if (event.idClub == game.idClubLeft) {
            leftClubScore++;
          } else if (event.idClub == game.idClubRight) {
            rightClubScore++;
          }
        }

        // return buildGoalEventListItem(context, goalEvent, game);
        return buildFullReportListItem(context, event, leftClubScore,
            rightClubScore, game, initialExpanded);
      },
    ),
  );
}

Widget buildFullReportListItem(BuildContext context, GameEvent event,
    int leftClubScore, int rightClubScore, Game game, bool initialExpanded) {
  return ExpansionTile(
    initiallyExpanded: initialExpanded,
    leading: Text(
      event.getMinute(),
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    title: Row(
      mainAxisAlignment: event.idClub == game.idClubLeft
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
      children: [
        if (event.eventType.toUpperCase() == 'GOAL')
          getScoreRowFromScore(leftClubScore, rightClubScore, game.isCup,
              isLeftClubSelected: game.isLeftClubSelected),
        if (event.eventType.toUpperCase() != 'GOAL') formSpacer6,
        event.getEventPresentation(context),
      ],
    ),
    shape: shapePersoRoundedBorder(),
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            if (event.idClub == game.idClubRight) SizedBox(width: 36),
            Expanded(
              child: RichText(
                text: stringParser(context, event.getEventDescription(context),
                    colorDefaultText: Colors.blueGrey),
              ),
            ),
            if (event.idClub == game.idClubLeft) SizedBox(width: 36),
          ],
        ),
      ),
    ],
  );
}
