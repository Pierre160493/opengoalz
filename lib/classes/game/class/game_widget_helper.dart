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
            : getScoreRow(),
        SizedBox(width: 3),
        rightClub.getClubNameClickable(context, isRightClub: true),
      ],
    );
  }

  Widget getScoreRow() {
    if (dateEnd == null)
      return Icon(Icons.sync, size: iconSizeSmall);
    // Row(
    //   children: [
    //     Text(
    //       ' : ',
    //       style:
    //           TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
    //     ),
    //   ],
    // );
    else if (scoreLeft == null && scoreRight == null)
      return Text('ERR: Unknown left and right score of the game $id');
    else if (scoreRight == null)
      return Text('ERR: Unknown left score of the game $id');
    else if (scoreRight == null)
      return Text('ERR: Unknown right score of the game $id');

    // If the game is a cup, display the score of the penalty shootout
    int? leftPenaltyScore = null;
    int? rightPenaltyScore = null;
    if (isCup) {
      if (scoreCumulLeft != null && scoreCumulRight != null) {
        leftPenaltyScore = (scoreCumulLeft! % 1 * 1000).toInt();
        rightPenaltyScore = (scoreCumulRight! % 1 * 1000).toInt();
      } else {
        return Text('ERR: Unknown cumul score of the game $id');
      }
    }

    /// Default white colors
    Color leftColor = Colors.white;
    Color rightColor = Colors.white;
    Color colorLeftPenalty = Colors.white;
    Color colorRightPenalty = Colors.white;
    print('getScoreRow: isLeftClubSelected= ' + isLeftClubSelected.toString());

    /// If no club is selected
    if (isLeftClubSelected == null) {
      // if (scoreLeft! > scoreRight!) {
      //   leftColor = Colors.green;
      //   rightColor = Colors.red;
      // } else if (scoreLeft! < scoreRight!) {
      //   leftColor = Colors.red;
      //   rightColor = Colors.green;
      // } else if (scoreLeft! == scoreRight!) {
      //   leftColor = Colors.blueGrey;
      //   rightColor = Colors.blueGrey;
      // }
      // if (isCup && leftPenaltyScore != null && rightPenaltyScore != null) {
      //   if (leftPenaltyScore > rightPenaltyScore) {
      //     colorLeftPenalty = Colors.green;
      //     colorRightPenalty = Colors.red;
      //   } else {
      //     colorLeftPenalty = Colors.red;
      //     colorRightPenalty = Colors.green;
      //   }
      // }

      /// If the left club is selected
    } else if (isLeftClubSelected!) {
      if (scoreLeft! > scoreRight!) {
        leftColor = Colors.green;
        rightColor = Colors.green;
      } else if (scoreLeft! < scoreRight!) {
        leftColor = Colors.red;
        rightColor = Colors.red;
      } else if (scoreLeft! == scoreRight!) {
        leftColor = Colors.blueGrey;
        rightColor = Colors.blueGrey;
      }
      if (isCup && leftPenaltyScore != null && rightPenaltyScore != null) {
        if (leftPenaltyScore > rightPenaltyScore) {
          colorLeftPenalty = Colors.green;
          colorRightPenalty = Colors.green;
        } else {
          colorLeftPenalty = Colors.red;
          colorRightPenalty = Colors.red;
        }
      }
    }

    /// If the left club is selected
    else if (!isLeftClubSelected!) {
      if (scoreLeft! > scoreRight!) {
        leftColor = Colors.red;
        rightColor = Colors.red;
      } else if (scoreLeft! < scoreRight!) {
        leftColor = Colors.green;
        rightColor = Colors.green;
      } else if (scoreLeft! == scoreRight!) {
        leftColor = Colors.blueGrey;
        rightColor = Colors.blueGrey;
      }
      if (isCup && leftPenaltyScore != null && rightPenaltyScore != null) {
        if (leftPenaltyScore > rightPenaltyScore) {
          colorLeftPenalty = Colors.red;
          colorRightPenalty = Colors.red;
        } else {
          colorLeftPenalty = Colors.green;
          colorRightPenalty = Colors.green;
        }
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            scoreLeft.toString(),
            style: TextStyle(
              // color: leftPenaltyScore == null ? colorLeftPenalty : null,
              color: leftColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (leftPenaltyScore != null)
            Text(
              ' [${leftPenaltyScore.toString()}]',
              style: TextStyle(
                color: colorLeftPenalty,
                fontWeight: FontWeight.bold,
              ),
            ),
          Text(
            ' : ',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          if (rightPenaltyScore != null)
            Text(
              '[${rightPenaltyScore.toString()}] ',
              style: TextStyle(
                color: colorRightPenalty,
                fontWeight: FontWeight.bold,
              ),
            ),
          Text(
            scoreRight.toString(),
            style: TextStyle(
              // color: rightPenaltyScore == null ? colorRightPenalty : null,
              color: leftColor,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  // Widget getGameDetails(BuildContext context, {int? idClubSelected = null}) {
  Widget getGameDetails(BuildContext context) {
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
                              Text('First Leg Game '),
                              // If the game is played, display the score
                              if (dateEnd != null)
                                // If the score is available, display it
                                if (scoreCumulLeft != null &&
                                    scoreCumulRight != null &&
                                    scoreLeft != null &&
                                    scoreRight != null)
                                  Text(
                                      'Score: ${scoreCumulLeft!.toInt() - scoreLeft!.toInt()} - ${scoreCumulRight!.toInt() - scoreLeft!.toInt()}')
                                else
                                  Text(
                                      'ERROR: Cannot fetch the first leg score')
                              // Then the game is not played so scoreCumul stores the first leg score
                              else if (scoreCumulLeft != null &&
                                  scoreCumulRight != null)
                                Text(
                                    'Score: ${scoreCumulLeft!.toInt()} - ${scoreCumulRight!.toInt()}')
                              // else
                              //   Text('ERROR: Cannot fetch the final score')
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

  Widget getGameReport(BuildContext context) {
    int leftClubScore = 0;
    int rightClubScore = 0;

    if (events.length == 0) return Center(child: Text('No events found'));

    return Column(
      children: [
        SizedBox(
          height: 12,
        ),
        getGameRow(context, isSpaceEvenly: true),
        SizedBox(
          height: 12,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              if (index == 0) {
                leftClubScore = 0;
                rightClubScore = 0;
              }

              // Update scores based on event type (assuming event type 1 is a goal)
              if (event.idEventType == 1) {
                if (event.idClub == idClubLeft) {
                  leftClubScore++;
                } else if (event.idClub == idClubRight) {
                  rightClubScore++;
                }
              }

              return ListTile(
                leading: Container(
                  width: 100, // Fixed width to ensure alignment
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueGrey,
                        ),
                        child: Center(
                          child: Text(
                            '${event.gameMinute.toString()}\'',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      if (event.idEventType == 1) // Conditionally display score
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$leftClubScore - $rightClubScore',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                title: Row(
                  children: [
                    event.idClub == idClubRight ? Spacer() : SizedBox(width: 6),
                    event.getDescription(context),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
