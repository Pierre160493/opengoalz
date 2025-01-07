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

  Widget getGameRow(BuildContext context, {bool isSpaceEvenly = false}) {
    return Row(
      mainAxisAlignment: isSpaceEvenly
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.start,
      children: [
        leftClub.getClubNameClickable(context),
        SizedBox(width: 3),
        // If dateEnd is null, the game is not played yet
        dateEnd == null
            // ? Text('VS')
            ? Icon(Icons.sync, size: iconSizeSmall)
            : getScoreRowFromGame(this),
        SizedBox(width: 3),
        rightClub.getClubNameClickable(context, isRightClub: true),
      ],
    );
  }

  // Widget getScoreRow() {
  //   /// If the game is not played yet
  //   if (isPlaying == null)
  //     return Icon(Icons.sync, size: iconSizeSmall);
  //   // Row(
  //   //   children: [
  //   //     Text(
  //   //       ' : ',
  //   //       style:
  //   //           TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
  //   //     ),
  //   //   ],
  //   // );
  //   else if (scoreLeft == null && scoreRight == null)
  //     return Text('ERROR: Unknown left and right score of the game $id');
  //   else if (scoreRight == null)
  //     return Text('ERROR: Unknown left score of the game $id');
  //   else if (scoreRight == null)
  //     return Text('ERROR: Unknown right score of the game $id');

  //   /// Default white colors
  //   Color leftColor = Colors.white;
  //   Color rightColor = Colors.white;
  //   Color colorLeftPenalty = Colors.white;
  //   Color colorRightPenalty = Colors.white;

  //   /// If the left club is selected
  //   if (isLeftClubSelected == true) {
  //     if (scoreLeft! > scoreRight!) {
  //       leftColor = Colors.green;
  //       rightColor = Colors.green;
  //     } else if (scoreLeft! < scoreRight!) {
  //       leftColor = Colors.red;
  //       rightColor = Colors.red;
  //     } else if (scoreLeft! == scoreRight!) {
  //       leftColor = Colors.blueGrey;
  //       rightColor = Colors.blueGrey;
  //     }
  //     // if (isCup && scorePenaltyLeft != null && scorePenaltyRight != null) {
  //     if (scorePenaltyLeft != null && scorePenaltyRight != null) {
  //       if (scorePenaltyLeft! > scorePenaltyRight!) {
  //         colorLeftPenalty = Colors.green;
  //         colorRightPenalty = Colors.green;
  //       } else {
  //         colorLeftPenalty = Colors.red;
  //         colorRightPenalty = Colors.red;
  //       }
  //     }
  //   }

  //   /// If the left club is selected
  //   else if (isLeftClubSelected == false) {
  //     if (scoreLeft! > scoreRight!) {
  //       leftColor = Colors.red;
  //       rightColor = Colors.red;
  //     } else if (scoreLeft! < scoreRight!) {
  //       leftColor = Colors.green;
  //       rightColor = Colors.green;
  //     } else if (scoreLeft! == scoreRight!) {
  //       leftColor = Colors.blueGrey;
  //       rightColor = Colors.blueGrey;
  //     }
  //     // if (isCup && scorePenaltyLeft != null && scorePenaltyRight != null) {
  //     if (scorePenaltyLeft != null && scorePenaltyRight != null) {
  //       if (scorePenaltyLeft! > scorePenaltyRight!) {
  //         colorLeftPenalty = Colors.red;
  //         colorRightPenalty = Colors.red;
  //       } else {
  //         colorLeftPenalty = Colors.green;
  //         colorRightPenalty = Colors.green;
  //       }
  //     }
  //   }

  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 6),
  //     decoration: BoxDecoration(
  //       color: Colors.black,
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     child: Row(
  //       children: [
  //         Text(
  //           // If the score is -1, display 0F for forfeit
  //           scoreLeft == -1 ? '0(F)' : scoreLeft.toString(),
  //           style: TextStyle(
  //             // color: scorePenaltyLeft == null ? colorLeftPenalty : null,
  //             color: leftColor,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         if (scorePenaltyLeft != null)
  //           Text(
  //             ' [${scorePenaltyLeft.toString()}]',
  //             style: TextStyle(
  //               color: colorLeftPenalty,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         Text(
  //           ' : ',
  //           style:
  //               TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
  //         ),
  //         if (scorePenaltyRight != null)
  //           Text(
  //             '[${scorePenaltyRight.toString()}] ',
  //             style: TextStyle(
  //               color: colorRightPenalty,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         Text(
  //           scoreRight == -1 ? '0(F)' : scoreRight.toString(),
  //           style: TextStyle(
  //             // color: scorePenaltyRight == null ? colorRightPenalty : null,
  //             color: rightColor,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget getGamePresentation(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getGameIcon(),
            SizedBox(width: 12.0),
            Expanded(
                child: Column(
              children: [
                getGameRow(context, isSpaceEvenly: true),
                SizedBox(
                  height: 12,
                ),

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
                              SizedBox(width: 3),
                              Text('First Leg Game: '),
                              Text(
                                  '${scorePreviousLeft == null ? '?' : scorePreviousLeft} - ${scorePreviousRight == null ? '?' : scorePreviousRight}'),
                            ],
                          )),
                    ],
                  ),
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
                SizedBox(
                  height: 6,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                    ),
                    // Text(' Date: '),
                    Text(
                      DateFormat(' dd/MM HH:mm').format(dateStart),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Icon(
                      Icons.calendar_month_outlined,
                    ),
                    Text(
                      ' Week: $weekNumber',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
