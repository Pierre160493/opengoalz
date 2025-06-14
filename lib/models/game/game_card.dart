import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/game/scoreWidget.dart';
import 'package:opengoalz/models/game/gameIconWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/pages/game_page.dart';

class GameCardWidget extends StatelessWidget {
  final Game game;
  final Player? player;

  const GameCardWidget(
    this.game, {
    Key? key,
    this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.blueGrey,
          width: 3.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Icon of the game
            getGameIcon(context, game),
            formSpacer12,
            Expanded(
                child: Column(
              children: [
                game.getGameResultRow(context, isSpaceEvenly: true),

                /// If this is a return game of a two games round, display the score
                if (game.isReturnGameIdGameFirstRound != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              GamePage.route(
                                  game.isReturnGameIdGameFirstRound!,
                                  game.isLeftClubSelected == null
                                      ? 0
                                      : game.isLeftClubSelected!
                                          ? game.idClubLeft
                                          : game.idClubRight),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.queue_play_next, color: Colors.green),
                              formSpacer3,
                              Text('First Leg Game: ',
                                  style: TextStyle(color: Colors.blueGrey)),
                              getScoreRowFromScore(game.scorePreviousLeft,
                                  game.scorePreviousRight, false,
                                  isLeftClubSelected: game.isLeftClubSelected),
                              // Text(
                              //     '${scorePrehhhviousLeft == null ? '?' : scorePreviousLeft} - ${scorePreviousRight == null ? '?' : scorePreviousRight}'),
                            ],
                          )),
                    ],
                  ),
                game.getGameEloRow(context, game.eloLeft, game.eloRight),
                Row(
                  children: [
                    const Icon(
                      Icons.description,
                      color: Colors.green,
                    ),
                    Expanded(
                      child: Text(
                        // idDescription.toString(),
                        game.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: Colors.green,
                    ),
                    Text(
                      DateFormat(' dd/MM HH:mm').format(game.dateStart),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    Spacer(),
                    Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.green,
                    ),
                    Text(
                      ' S${game.seasonNumber} W${game.weekNumber}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
