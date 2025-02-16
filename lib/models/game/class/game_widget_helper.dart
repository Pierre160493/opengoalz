part of 'game.dart';

extension GameClassWidgetHelper on Game {
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
        Tooltip(
          message: 'Left club expected win rate',
          child: Row(
            children: [
              Icon(
                Icons.balance,
                color: Colors.green,
              ),
              expectedEloResult == null
                  ? Text('?',
                      style: TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold))
                  : InkWell(
                      child: Text(
                        expectedEloResult!.last.toStringAsFixed(2),
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            final chartData = ChartData(
                              title:
                                  'Expected win rate evolution of the left club',
                              yValues: [
                                expectedEloResult!.map((e) => e * 100).toList()
                              ],
                              typeXAxis: XAxisType.gameMinute,
                            );

                            return ChartDialogBox(chartData: chartData);
                          },
                        );
                      },
                    ),
              if (eloExchangedPoints != null)
                Tooltip(
                  message: 'Number of elo points won',
                  child: Row(
                    children: [
                      Icon(
                        Icons.swap_horizontal_circle,
                        color: Colors.green,
                      ),
                      Text(
                        eloExchangedPoints == null
                            ? '?'
                            : eloExchangedPoints.toString(),
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
        clubEloRow(context, idClubRight, eloRight),
      ],
    );
  }
}
