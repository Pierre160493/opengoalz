part of 'game.dart';

extension GameClassWidgetHelper on Game {
  Widget getGameRow(BuildContext context, {bool isSpaceEvenly = false}) {
    return Row(
      mainAxisAlignment: isSpaceEvenly
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.start,
      children: [
        leftClub.getClubNameClickable(context),
        SizedBox(width: 6),
        isPlayed ? getScoreRow() : Text('VS'),
        SizedBox(width: 6),
        rightClub.getClubNameClickable(context, isRightClub: true),
      ],
    );
  }

  Widget getScoreRow() {
    List<GameEvent> scoreEvents =
        events.where((event) => event.idEventType == 1).toList();
    int leftClubScore =
        scoreEvents.where((event) => event.idClub == idClubLeft).length;
    int rightClubScore =
        scoreEvents.where((event) => event.idClub == idClubRight).length;

    Color leftColor = Colors.white;
    Color rightColor = Colors.white;
    if (leftClubScore > rightClubScore) {
      leftColor = Colors.green;
      rightColor = Colors.red;
    } else if (leftClubScore < rightClubScore) {
      leftColor = Colors.red;
      rightColor = Colors.green;
    }

    Row row = Row(
      children: [
        SizedBox(
          width: 6,
        ),
        Icon(
          Icons.handshake,
// Icons.compare_arrows,
          size: 30,
          color: Colors.blueGrey,
        ),
        SizedBox(
          width: 6,
        )
      ],
    );

    if (isPlayed == false) return row;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            leftClubScore.toString(),
            style: TextStyle(
              fontSize: 24.0,
              color: leftColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          row,
          Text(
            rightClubScore.toString(),
            style: TextStyle(
              fontSize: 24.0,
              color: rightColor,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

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
            Icon(
                // Icons.military_tech,
                // Icons.sports_score,
                Icons.emoji_events_outlined,
                size: 60,
                color: Colors.green),
            SizedBox(width: 12.0),
            Expanded(
                child: Column(
              children: [
                getGameRow(context, isSpaceEvenly: true),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Icon(Icons.timer_outlined),
                    // Text(' Date: '),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm:ss').format(dateStart),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    const Icon(Icons.calendar_month_outlined),
                    Text(
                      ' Week Day ${weekNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
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
                                  fontSize: 16.0,
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