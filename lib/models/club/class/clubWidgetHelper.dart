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
        Icon(iconLeague, color: Colors.green),
        formSpacer3,
        Text(
            positionWithIndex(clubData.posLeague) +
                ' with ${clubData.leaguePoints} points',
            style: styleItalicBlueGrey),
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

    const boldTextStyle = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      children: [
        Icon(Icons.emoji_events, color: Colors.yellow),
        formSpacer3, // Assuming formSpacer3 is defined elsewhere
        Text(
          victories.toString(),
          style: boldTextStyle.copyWith(color: Colors.green),
        ),
        Text(' / '),
        Text(
          draws.toString(),
          style: boldTextStyle.copyWith(color: Colors.grey),
        ),
        Text(' / '),
        Text(
          losses.toString(),
          style: boldTextStyle.copyWith(color: Colors.red),
        ),
      ],
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
              color: goalDifference > 0
                  ? Colors.green
                  : goalDifference == 0
                      ? Colors.blueGrey
                      : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(' ('), // Preserving original spacing
          Text(
            goalsFor.toString(),
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('/'),
          Text(
            goalsAgainst.toString(),
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(') '), // Preserving original spacing
          Icon(Icons.sports_soccer, color: Colors.blueGrey),
        ],
      ),
    );
  }

  Widget getQuickAccessWidget(BuildContext context, Profile user) {
    double containerWidth = 80;
    double containerImgRadius = 24;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      /// Players box
      Container(
        width: containerWidth, // Fixed width for each tile
        height: containerWidth, // Fixed height for each tile
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(6), // Adjust border radius as needed
          border: Border.all(
            color: Colors.green, // Border color
          ),
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
                  Text(user.selectedClub!.numberPlayers.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(' Players'),
                ],
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              /// Favorite icon button for opening scouts page
              SizedBox(
                width: iconSizeSmall * 1.5,
                height: iconSizeSmall * 1.5,
                child: IconButton(
                  tooltip:
                      '${user.selectedClub!.playersFavorite.length} Favorite Players',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScoutsPage(
                            initialTab: ScoutsPageTab.followedPlayers),
                      ),
                    );
                  },
                  icon: Icon(iconFavorite,
                      color: Colors.red, size: iconSizeSmall),
                ),
              ),

              /// Poaching icon button for opening scouts page
              SizedBox(
                width: iconSizeSmall * 1.5,
                height: iconSizeSmall * 1.5,
                child: IconButton(
                  tooltip:
                      '${user.selectedClub!.playersPoached.length} Poached Players',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScoutsPage(
                            initialTab: ScoutsPageTab.poachedPlayers),
                      ),
                    );
                  },
                  icon: Icon(iconPoaching,
                      color: Colors.red, size: iconSizeSmall),
                ),
              ),
            ]),

            // CircleAvatar(
            //   radius: containerImgRadius,
            //   child: Icon(
            //     iconPlayers,
            //     size: containerImgRadius,
            //   ),
            // ),
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
            width: containerWidth, // Fixed width for each tile
            height: containerWidth, // Fixed height for each tile
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(6), // Adjust border radius as needed
              border: Border.all(
                color: Colors.green, // Border color
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
                color: Colors.green, // Border color
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
                  idSelectedClub: user.selectedClub!.id,
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
                color: Colors.green, // Border color
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
