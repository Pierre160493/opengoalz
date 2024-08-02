part of 'club.dart';

extension ClubWidgetHelper on Club {
  Widget getClubName(BuildContext context, {bool isRightClub = false}) {
    bool isMine =
        Provider.of<SessionProvider>(context).user!.selectedClub.id == id;
    Text text = Text(
      nameClub,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontStyle: isMine ? FontStyle.italic : FontStyle.normal,
      ),
      overflow: TextOverflow.fade, // or TextOverflow.ellipsis
      maxLines: 1,
      softWrap: false,
    );
    Icon icon = Icon(isMine ? icon_home : Icons.sports_soccer_outlined);

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
    return Text('Since: ${DateFormat.yMMMMd('en_US').format(createdAt)}');
  }

  Widget getQquickAccessWidget(BuildContext context) {
    double containerWidth = 80;
    double containerImgRadius = 24;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      /// Players box
      InkWell(
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
              // Text('Players [${club.player_count}]'),
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

      /// Transfers box
      InkWell(
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
                  icon_transfers,
                  size: containerImgRadius,
                ),
              ),
            ],
          ),
        ),
      ),

      /// Games box
      InkWell(
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
                  icon_games,
                  size: containerImgRadius,
                ),
              ),
            ],
          ),
        ),
      ),

      /// Ranking box
      InkWell(
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
    ]);
  }
}