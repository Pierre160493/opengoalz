part of 'game.dart';

extension GameClassWidgetHelper on Game {
  /// Icon of the game: cup, league, friendly, relegation
  Widget getGameIcon() {
    // Icon of the game: cup, league, friendly, relegation
    Icon Mainicon = Icon(
      isRelegation
          ? Icons.expand
          : isFriendly
              ? Icons.handshake
              : Icons.emoji_events_outlined,
      size: 60,
      color: Colors.yellow,
    );

    // Text under the icon
    Text text = Text(
      weekNumber < 11 ? ' ${weekNumber}/10' : ' Inter ${weekNumber - 10}',
      style: TextStyle(
        color: Colors.blueGrey,
      ),
    );

    Icon programIcon = Icon(
      weekNumber < 11
          ? Icons.calendar_month_outlined
          : Icons.format_list_bulleted_add,
      color: Colors.blueGrey,
    );

    return Column(children: [
      Mainicon,
      Row(
        children: [
          programIcon,
          text,
        ],
      )
    ]);
  }

  // Widget getGameRow(BuildContext context, {bool isSpaceEvenly = false}) {
  //   return Column(
  //     children: [
  //       getGameResultRow(context, isSpaceEvenly: isSpaceEvenly),

  //       /// Row for the game elo calculation
  //       getGameEloRow(context, eloLeft, eloRight),
  //     ],
  //   );
  // }

  Widget getGameResultRow(BuildContext context, {bool isSpaceEvenly = false}) {
    return Row(
      mainAxisAlignment: isSpaceEvenly
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.start,
      children: [
        leftClub.getClubNameClickable(context),
        formSpacer3,
        // If isPlaying is null, the game has not started yet, if true, the game is in progress
        isPlaying == null
            ? Icon(Icons.sync, size: iconSizeSmall, color: Colors.green)
            : isPlaying == true
                ? Icon(iconGameIsPlaying,
                    size: iconSizeSmall, color: Colors.green)
                : getScoreRowFromGame(this),
        formSpacer3,
        rightClub.getClubNameClickable(context, isRightClub: true),
      ],
    );
  }

  Widget getGameEloRow(BuildContext context, int? eloLeft, int? eloRight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        clubEloRow(context, idClubLeft, eloLeft),
        Row(
          children: [
            Icon(
              Icons.balance,
              color: Colors.green,
            ),
            Tooltip(
              message: 'Left club expected win rate',
              child: Text(
                expectedEloResult == null
                    ? '?'
                    : expectedEloResult!.toStringAsFixed(2),
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        clubEloRow(context, idClubRight, eloRight),
      ],
    );
  }

  // Widget rowEloScore(int? eloScore) {
  //   return Tooltip(
  //     message: 'Elo score of the club',
  //     child: Row(
  //       children: [
  //         Icon(
  //           iconElo,
  //           color: Colors.green,
  //         ),
  //         Text(
  //           eloScore.toString(),
  //           style: TextStyle(
  //             color: Colors.blueGrey,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget getGamePresentation(BuildContext context) {
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
            getGameIcon(),
            formSpacer12,
            Expanded(
                child: Column(
              children: [
                getGameResultRow(context, isSpaceEvenly: true),

                /// If this is a return game of a two games round, display the score
                if (isReturnGameIdGameFirstRound != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              GamePage.route(
                                  isReturnGameIdGameFirstRound!,
                                  isLeftClubSelected == null
                                      ? 0
                                      : isLeftClubSelected!
                                          ? idClubLeft
                                          : idClubRight),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.queue_play_next),
                              formSpacer3,
                              Text('First Leg Game: '),
                              Text(
                                  '${scorePreviousLeft == null ? '?' : scorePreviousLeft} - ${scorePreviousRight == null ? '?' : scorePreviousRight}'),
                            ],
                          )),
                    ],
                  ),
                getGameEloRow(context, eloLeft, eloRight),
                Row(
                  children: [
                    const Icon(
                      Icons.description,
                      color: Colors.blueGrey,
                    ),
                    Expanded(
                      child: Text(
                        // idDescription.toString(),
                        description,
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
                      color: Colors.blueGrey,
                    ),
                    // Text(' Date: '),
                    Text(
                      DateFormat(' dd/MM HH:mm').format(dateStart),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    Spacer(),
                    Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.blueGrey,
                    ),
                    Text(
                      ' Week: $weekNumber',
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
