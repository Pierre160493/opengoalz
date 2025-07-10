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

  /// Legacy method wrapper for backward compatibility
  ///
  /// **Deprecated**: Use PlayerMainInformation widget instead
  @Deprecated('Use PlayerMainInformation widget instead')
  Widget getPlayerMainInformation(BuildContext context) {
    return PlayerMainInformation(player: this);
  }

  static double iconSize = iconSizeSmall;

  // Widget getAgeWidget() {
  //   return ListTile(
  //     shape: shapePersoRoundedBorder(),
  //     // leading: Icon(
  //     //   Icons.cake_outlined,
  //     //   size: iconSize,
  //     // ),
  //     title: Row(
  //       children: [
  //         Icon(iconAge, size: iconSize),
  //         getAgeStringRow(age, multiverseSpeed),
  //       ],
  //     ),
  //     subtitle: Row(
  //       children: [
  //         Icon(Icons.event, size: iconSize),
  //         formSpacer3,
  //         Text(DateFormat('dd MMMM yyyy').format(dateBirth),
  //             style: TextStyle(
  //                 fontStyle: FontStyle.italic, color: Colors.blueGrey)),
  //       ],
  //     ),
  //   );
  // }

  Widget getAgeWidgetSmall() {
    return Tooltip(
      message: getAgeString(age),
      child: Row(
        children: [
          Icon(iconAge, size: iconSizeSmall, color: Colors.green),
          Text(
            age.toStringAsFixed(0),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Generate ico of the player based on the last digit of the player id
  IconData getPlayerIcon() {
    switch (id % 10) {
      case 0:
        return Icons.person;
      case 1:
        return Icons.face_5;
      case 2:
        return Icons.person_3;
      case 3:
        return Icons.person_4;
      case 4:
        return Icons.person_outline;
      case 5:
        return Icons.person_pin;
      case 6:
        return Icons.face_6;
      case 7:
        return Icons.person_pin_rounded;
      case 8:
        return Icons.person_2;
      case 9:
        return Icons.face;
      default:
        return Icons.error;
    }
  }
}
