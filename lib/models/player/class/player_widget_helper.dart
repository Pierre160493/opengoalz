part of 'player.dart';

extension PlayerWidgetsHelper on Player {
  String getPlayerNameString({bool isSurname = false}) {
    return isSurname
        ? surName == null
            ? 'No Surname'
            : surName!
        : '${firstName[0]}.${lastName.toUpperCase()}';
  }

  Widget getPlayerNameTextWidget(BuildContext context,
      {bool isSurname = false}) {
    return Text(
      getPlayerNameString(isSurname: isSurname),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isEmbodiedByCurrentUser
            ? colorIsMine
            : isPartOfClubOfCurrentUser
                ? colorIsSelected
                : null,
      ),
      overflow: TextOverflow.fade, // or TextOverflow.ellipsis
      maxLines: 1,
      softWrap: false,
    );
  }

  /// Clickable widget of the club name
  Widget getPlayerNameClickable(BuildContext context,
      {bool isRightClub = false, bool isSurname = false}) {
    return Row(
      // mainAxisAlignment:
      //     isRightClub ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayersPage(
                  playerSearchCriterias: PlayerSearchCriterias(idPlayer: [id]),
                ),
              ),
            );
          },
          child: PlayerNameTooltip(player: this, isSurname: isSurname),
        ),
      ],
    );
  }

  static double iconSize = iconSizeSmall;

  Widget getAgeWidgetSmall() {
    return Tooltip(
      message: getAgeString(age),
      child: Row(
        children: [
          Icon(iconAge, size: iconSizeSmall, color: Colors.green),
          Text(
            age.toStringAsFixed(0),
            style:
                TextStyle(fontSize: fontSizeSmall, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
