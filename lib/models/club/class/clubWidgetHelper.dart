part of 'club.dart';

extension ClubWidgetHelper on Club {
  Widget getClubName(BuildContext context, {bool isRightClub = false}) {
    Profile connectedUser =
        Provider.of<UserSessionProvider>(context, listen: false).user;

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

    Widget text = Text(
      name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: color,
        fontSize: fontSizeMedium,
      ),
      overflow: TextOverflow.ellipsis,
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

  Widget getClubRankingRow(BuildContext context) {
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
        Icon(iconLeague, color: Colors.green, size: iconSizeSmall),
        formSpacer3,
        Text(
            positionWithIndex(clubData.posLeague) +
                ' with ${clubData.leaguePoints} points',
            style: styleItalicBlueGrey.copyWith(fontSize: fontSizeSmall)),
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
                fontSize: fontSizeSmall,
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

  Widget getClubResultsVDLRow() {
    int victories = 0;
    int draws = 0;
    int losses = 0;

    for (final result in lisLastResults.take(10)) {
      switch (result) {
        case 3:
          victories++;
          break;
        case 1:
          draws++;
          break;
        case 0:
          losses++;
          break;
        default:
          // If an invalid result is found, throw an exception.
          // Consider if this is the desired behavior or if errors should be logged/ignored.
          throw Exception(
              'Invalid result value: $result. Expected 0, 1, or 3.');
      }
    }

    return Tooltip(
      message:
          'Last 10 results: $victories victories / $draws draws / $losses losses',
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            size: iconSizeSmall,
            color: Colors.yellow,
          ),
          formSpacer3, // Assuming formSpacer3 is defined elsewhere
          Text(
            victories.toString(),
            // style: boldTextStyle.copyWith(color: Colors.green),
            style: TextStyle(
              fontSize: fontSizeMedium,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(' / ', style: TextStyle(fontSize: fontSizeMedium)),
          Text(
            draws.toString(),
            style: TextStyle(
              fontSize: fontSizeMedium,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          Text(' / ', style: TextStyle(fontSize: fontSizeMedium)),
          Text(
            losses.toString(),
            style: TextStyle(
              fontSize: fontSizeMedium,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget getClubGoalsForAndAgainstRow() {
    final int goalsFor = clubData.leagueGoalsFor;
    final int goalsAgainst = clubData.leagueGoalsAgainst;
    final int goalDifference = goalsFor - goalsAgainst;

    return Tooltip(
      message: 'Goal Difference (Goals For / Against)',
      child: Row(
        children: [
          Text(
            '${goalDifference > 0 ? '+' : ''}$goalDifference',
            style: TextStyle(
              fontSize: fontSizeMedium,
              color: goalDifference > 0
                  ? Colors.green
                  : goalDifference == 0
                      ? Colors.blueGrey
                      : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(' (', style: TextStyle(fontSize: fontSizeMedium)),
          Text(
            goalsFor.toString(),
            style: TextStyle(
              fontSize: fontSizeMedium,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('/', style: TextStyle(fontSize: fontSizeMedium)),
          Text(
            goalsAgainst.toString(),
            style: TextStyle(
              fontSize: fontSizeMedium,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(') ', style: TextStyle(fontSize: fontSizeMedium)),
          Icon(Icons.sports_soccer,
              size: iconSizeSmall, color: Colors.blueGrey),
        ],
      ),
    );
  }

  Widget getQuickAccessWidget(BuildContext context, Profile user) {
    // Use icon and font size constants for scalable, consistent sizing
    double containerWidth = iconSizeLarge * 2.6;
    double containerImgRadius = iconSizeMedium * 0.8;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      /// Players box
      Container(
        width: containerWidth,
        height: containerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayersPage(
                      playerSearchCriterias:
                          PlayerSearchCriterias(idClub: [id], retired: false),
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    user.selectedClub!.numberPlayers.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeSmall,
                    ),
                  ),
                  Text(
                    ' Players',
                    style: TextStyle(fontSize: fontSizeSmall),
                  ),
                ],
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              IconButton(
                tooltip:
                    '${user.selectedClub!.playersFavorite.length} Favorite Players',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScoutsPage(initialTab: ScoutsPageTab.followedPlayers),
                    ),
                  );
                },
                icon:
                    Icon(iconFavorite, color: Colors.red, size: iconSizeSmall),
              ),
              IconButton(
                tooltip:
                    '${user.selectedClub!.playersPoached.length} Poached Players',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScoutsPage(initialTab: ScoutsPageTab.poachedPlayers),
                    ),
                  );
                },
                icon:
                    Icon(iconPoaching, color: Colors.red, size: iconSizeSmall),
              ),
            ]),
          ],
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
            width: containerWidth,
            height: containerWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Transfers', style: TextStyle(fontSize: fontSizeSmall)),
                CircleAvatar(
                  radius: containerImgRadius,
                  child: Icon(
                    iconTransfers,
                    size: iconSizeMedium,
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
            width: containerWidth,
            height: containerWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Games', style: TextStyle(fontSize: fontSizeSmall)),
                CircleAvatar(
                  radius: containerImgRadius,
                  child: Icon(
                    iconGames,
                    size: iconSizeMedium,
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
                  idSelectedClub: user.selectedClub!.id,
                ),
              ),
            );
          },
          child: Container(
            width: containerWidth,
            height: containerWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('League', style: TextStyle(fontSize: fontSizeSmall)),
                CircleAvatar(
                  radius: containerImgRadius,
                  child: Icon(
                    iconLeague,
                    size: iconSizeMedium,
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
