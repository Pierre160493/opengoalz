part of 'club.dart';

extension ClubWidgetHelper on Club {
  Widget getClubName(BuildContext context, {bool isRightClub = false}) {
    /// If the club belongs to the current user
    bool isMine = Provider.of<SessionProvider>(context)
        .user!
        .clubs
        .map((Club club) => club.id)
        .toList()
        .contains(id);

    /// If the club is currently selected
    bool isSelected =
        Provider.of<SessionProvider>(context).user!.selectedClub!.id == id;
    Text text = Text(
      name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontStyle: isSelected ? FontStyle.italic : FontStyle.normal,
        color: isMine ? colorIsMine : null,
        decoration:
            isSelected ? TextDecoration.underline : null, // Add this line
      ),
      overflow: TextOverflow.fade, // or TextOverflow.ellipsis
      maxLines: 1,
      softWrap: false,
    );
    Icon icon = Icon(isSelected ? icon_home : Icons.sports_soccer_outlined);

    return Row(
      children: [
        if (isRightClub) text else icon,
        if (isRightClub) icon else text,
      ],
    );
  }

  /// Clickable widget of the club name
  Widget getClubNameClickable(BuildContext context,
      {bool isRightClub = false}) {
    return Tooltip(
      message: 'Open ${name} page',
      child: Row(
        mainAxisAlignment:
            isRightClub ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                ClubPage.route(id),
              );
            },
            child: getClubName(context, isRightClub: isRightClub),
          ),
        ],
      ),
    );
  }

  Widget getCreationWidget() {
    return Row(
      children: [
        Icon(iconHistory),
        SizedBox(width: 3),
        Text('Since: ${DateFormat.yMMMMd('en_US').format(createdAt)}'),
      ],
    );
  }

  Widget getRankingWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeaguePage(
              idLeague: idLeague,
            ),
          ),
        );
      },
      child: Row(children: [
        Icon(icon_league),
        SizedBox(width: 3),
        Text(
            '${posLeague == 1 ? "1st" : posLeague == 2 ? "2nd" : posLeague == 3 ? "3rd" : posLeague <= 6 ? "${posLeague}th" : posLeague} with ${leaguePoints.round()} points'),
      ]),
    );
  }

  Widget getLastResultsWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamesPage(
              idClub: id,
            ),
          ),
        );
      },
      child: lisLastResults.isEmpty
          ? Text(
              'No last results',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color:
                    Colors.blueGrey, // Replace "bluerey" with the desired color
              ),
            )
          : Tooltip(
              message: 'Last results (time from left to right)',
              child: Row(
                children: lisLastResults
                    .sublist(lisLastResults.length - 5 >= 0
                        ? lisLastResults.length - 5
                        : 0)
                    .map((result) {
                  return Icon(Icons.circle,
                      size: (iconSizeSmall / 1.5),
                      color: result == 3
                          ? Colors.green
                          : result == 0
                              ? Colors.red
                              : null); // Icon for victory
                }).toList(),
              ),
            ),
    );
  }

  Widget getQuickAccessWidget(BuildContext context, int? idSelectedClub) {
    double containerWidth = 80;
    double containerImgRadius = 24;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      /// Players box
      Tooltip(
        message: 'Open the Players page',
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayersPage(
                    // idClub: club.id_club,
                    inputCriteria: {
                      'Clubs': [id]
                    }),
              ),
            );
          },
          child: Container(
            width: containerWidth, // Fixed width for each tile
            height: containerWidth, // Fixed height for each tile
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(6), // Adjust border radius as needed
              border: Border.all(
                color: Colors.blueGrey, // Border color
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Players'),
                CircleAvatar(
                  radius: containerImgRadius,
                  child: Icon(
                    icon_players,
                    size: containerImgRadius,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /// Transfers box
      Tooltip(
        message: 'Open the Transfers page',
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransferPage(
                  idClub: id,
                ),
              ),
            );
          },
          child: Container(
            width: containerWidth, // Fixed width for each tile
            height: containerWidth, // Fixed height for each tile
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(6), // Adjust border radius as needed
              border: Border.all(
                color: Colors.blueGrey, // Border color
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Transfers'),
                CircleAvatar(
                  radius: containerImgRadius,
                  child: Icon(
                    iconTransfers,
                    size: containerImgRadius,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /// Games box

      Tooltip(
        message: 'Open the Games page',
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GamesPage(
                  idClub: id,
                ),
              ),
            );
          },
          child: Container(
            width: containerWidth, // Fixed width for each tile
            height: containerWidth, // Fixed height for each tile
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(6), // Adjust border radius as needed
              border: Border.all(
                color: Colors.blueGrey, // Border color
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Games'),
                CircleAvatar(
                  radius: containerImgRadius,
                  child: Icon(
                    iconGames,
                    size: containerImgRadius,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /// League box
      Tooltip(
        message: 'Open the League page',
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeaguePage(
                  idLeague: idLeague,
                  idSelectedClub: idSelectedClub,
                ),
              ),
            );
          },
          child: Container(
            width: containerWidth, // Fixed width for each tile
            height: containerWidth, // Fixed height for each tile
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(6), // Adjust border radius as needed
              border: Border.all(
                color: Colors.blueGrey, // Border color
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('League'),
                CircleAvatar(
                  radius: containerImgRadius,
                  child: Icon(
                    icon_league,
                    size: containerImgRadius,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}
