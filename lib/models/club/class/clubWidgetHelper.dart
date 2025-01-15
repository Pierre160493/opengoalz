part of 'club.dart';

extension ClubWidgetHelper on Club {
  Widget getClubName(BuildContext context, {bool isRightClub = false}) {
    Profile connectedUser =
        Provider.of<SessionProvider>(context, listen: false).user!;

    /// If the club belongs to the current user
    bool isMine =
        connectedUser.clubs.map((Club club) => club.id).toList().contains(id);

    /// If the club is currently selected
    bool isSelected = connectedUser.selectedClub?.id == id;

    /// If the club is the default club
    bool isDefault = connectedUser.idDefaultClub == id;

    Color color = isSelected
        ? colorIsSelected
        : isMine
            ? colorIsMine
            : colorDefault;

    Text text = Text(
      name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: color,
      ),
      overflow: TextOverflow.fade, // or TextOverflow.ellipsis
      maxLines: 1,
      softWrap: false,
    );
    // Icon icon = Icon(isSelected ? iconHome : Icons.sports_soccer_outlined);

    Icon icon = Icon(
        isDefault
            ? iconDefaultClub
            : isMine
                ? iconHome
                : userName == null
                    ? iconBot
                    : Icons.sports_soccer_outlined,
        color: color);

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
    return Row(
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
        Icon(iconLeague),
        SizedBox(width: 3),
        Text(
            '${clubData.posLeague == 1 ? "1st" : clubData.posLeague == 2 ? "2nd" : clubData.posLeague == 3 ? "3rd" : clubData.posLeague <= 6 ? "${clubData.posLeague}th" : clubData.posLeague} with ${clubData.leaguePoints.round()} points'),
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
                  playerSearchCriterias: PlayerSearchCriterias(idClub: [id]),
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
                Text('Players'),
                CircleAvatar(
                  radius: containerImgRadius,
                  child: Icon(
                    iconPlayers,
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
                    iconLeague,
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
