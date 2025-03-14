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
        color: isSelectedUserIncarnatedPlayer
            ? colorIsMine
            : isSelectedClubPlayer
                ? colorIsSelected
                : null,
      ),
      overflow: TextOverflow.fade, // or TextOverflow.ellipsis
      maxLines: 1,
      softWrap: false,
    );
  }

  Widget getPlayerNameToolTip(BuildContext context, {bool isSurname = false}) {
    return Tooltip(
      message: firstName + ' ' + lastName.toUpperCase(),
      child: getPlayerNameTextWidget(context, isSurname: isSurname),
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
          child: getPlayerNameToolTip(context),
        ),
      ],
    );
  }

  /// Returns the status of the player (on transfer list, being fired, injured, etc...)
  Widget getStatusRow() {
    DateTime currentDate = DateTime.now().toLocal();
    return Row(
      children: [
        if (dateBidEnd != null) ...[
          Tooltip(
            message:
                // 'Transfer List [${dateBidEnd!.difference(currentDate).inDays == 0 ? dateBidEnd!.difference(currentDate).inHours : dateBidEnd!.difference(currentDate).inDays} ${dateBidEnd!.difference(currentDate).inDays == 0 ? 'hours' : 'days'}]',
                'Auction deadline: ${DateFormat('EEE d \'at\' H:mm').format(dateBidEnd!)}',
            child: Stack(
              children: [
                Icon(
                  idClub == null
                      ? iconFreePlayer
                      : transferPrice! < 0
                          ? iconLeaveClub
                          : iconTransfers,
                  color: Colors.red,
                  size: iconSizeMedium,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Text(
                    () {
                      final difference = dateBidEnd!.difference(currentDate);
                      if (difference.inDays >= 1) {
                        return difference.inDays.toString() + 'd';
                      } else {
                        return difference.inHours.toString() + 'h';
                      }
                    }(),
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (dateEndInjury != null)
          Stack(
            children: [
              Icon(
                Icons.local_hospital,
                color: Colors.red,
                size: iconSizeMedium,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Text(
                  dateEndInjury!
                      .difference(currentDate)
                      .inDays
                      .toString(), // Change the number as needed
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        if (dateRetire != null)
          Tooltip(
            message:
                'Retired on ${DateFormat('EEE d MMM yyyy').format(dateRetire!)}',
            child: Icon(
              iconRetired,
              color: Colors.red,
              size: iconSizeMedium,
            ),
          ),
        if (dateDeath != null)
          Tooltip(
            message:
                'Died on ${DateFormat('EEE d MMM yyyy').format(dateDeath!)}',
            child: Icon(
              iconDead,
              color: Colors.red,
              size: iconSizeMedium,
            ),
          ),
        // if (is_currently_playing)
        //   const Icon(
        //     Icons.directions_run_outlined,
        //     color: Colors.green,
        //     size: 30,
        //   ),
      ],
    );
  }

  Widget getPlayerMainInformation(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > maxWidth / 2) {
          // Display information for larger screens
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: getAgeListTile(context, this)),
                  Expanded(
                      child: getCountryListTileFromIdCountry(
                          context, idCountry, idMultiverse)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: getPerformanceScoreListTile(context)),
                  Expanded(child: getExpensesWidget(context, this)),
                ],
              ),
              if (dateBidEnd != null) PlayerCardTransferWidget(player: this),
              if (dateEndInjury != null) getInjuryWidget(),
            ],
          );
        } else {
          // Display information for smaller screens
          return Column(
            children: [
              getAgeListTile(context, this),
              getCountryListTileFromIdCountry(context, idCountry, idMultiverse),
              getPerformanceScoreListTile(context),
              getExpensesWidget(context, this),
              if (dateBidEnd != null) PlayerCardTransferWidget(player: this),
              if (dateEndInjury != null) getInjuryWidget(),
            ],
          );
        }
      },
    );
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

  Widget getPerformanceScoreListTile(BuildContext context) {
    return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Icon(
        iconStats,
        size: iconSizeMedium,
        color: Colors.green,
      ),
      title: Text(
        performanceScore.toStringAsFixed(0),
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        'Performance Score',
        style: styleItalicBlueGrey,
      ),
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext context) {
          return getPlayerHistoryStreamGraph(context, id, ['performance_score'],
              'Performance Score History (${getShortName()})');
        },
      ),
    );
  }

  Widget getInjuryWidget() {
    return Row(
      children: [
        Icon(Icons.personal_injury_outlined,
            size: iconSize, color: Colors.red), // Adjust icon size and color
        Text(
          ' ${dateEndInjury!.difference(DateTime.now()).inDays.toString()}',
          style: const TextStyle(
            fontWeight: FontWeight.bold, // Remove bold font weight
            // color: Colors.red,
          ),
        ),
        Text(' days left for recovery')
      ],
    );
  }

  Widget getStatLinearWidget(String label, List<double> lisStatsHistoryAll,
      int weekOffsetToCompareWithNow, BuildContext context) {
    late IconData icon;
    String toolTipString = '';
    switch (label) {
      case 'Motivation':
        icon = iconMotivation;
        toolTipString = 'How motivated the player is';
        break;
      case 'Stamina':
        icon = iconStamina;
        toolTipString = 'How much stamina the player has';
        break;
      case 'Form':
        icon = iconForm;
        toolTipString = 'How good the player is currently playing';
        break;
      case 'Experience':
        icon = iconExperience;
        toolTipString = 'How experienced the player is';
        break;
      case 'Energy':
        icon = iconEnergy;
        toolTipString = 'How much energy the player has';
        break;
      case 'Loyalty':
        icon = Icons.loyalty;
        toolTipString = 'How loyal the player is to the club';
        break;
      case 'Leadership':
        icon = Icons.leaderboard;
        toolTipString = 'How good the player is at leading';
        break;
      case 'Discipline':
        icon = Icons.gavel;
        toolTipString = 'How disciplined the player is';
        break;
      case 'Communication':
        icon = Icons.chat;
        toolTipString = 'How good the player is at communicating';
        break;
      case 'Aggressivity':
        icon = Icons.sports_mma;
        toolTipString = 'How aggressive the player is';
        break;
      case 'Composure':
        icon = Icons.self_improvement;
        toolTipString = 'How well the player responds under pressure';
        break;
      case 'Teamwork':
        icon = Icons.group;
        toolTipString = 'How good the player is for playing in a team';
        break;
      default:
        icon = iconBug;
    }

    double valueNow = lisStatsHistoryAll.last;
    double valueOld = lisStatsHistoryAll[
        lisStatsHistoryAll.length - 1 - weekOffsetToCompareWithNow];

    return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Tooltip(
        message: toolTipString,
        child: Icon(
          icon,
          size: iconSize,
          color: valueNow > 50
              ? Colors.green
              : valueNow > 20
                  ? Colors.orange
                  : Colors.red,
        ),
      ),
      title: Row(
        children: [
          formSpacer6,
          Container(
            width: 100, // Fixed width for the label
            child: Text(label),
          ),
        ],
      ),
      subtitle: Stack(
        children: [
          /// Display the first bar (only if the values are different)
          if (valueNow != valueOld)
            Container(
              height: 12, // Set the desired height here
              // width: 120,
              child: LinearProgressIndicator(
                value: (max(valueNow, valueOld)) / 100,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(
                    valueNow > valueOld ? Colors.green : Colors.red),
              ),
            ),

          /// Display the second bar (on top of first)
          Container(
            height: 12, // Set the desired height here
            // width: 120,
            child: LinearProgressIndicator(
              value: min(valueNow, valueOld) / 100,
              backgroundColor:
                  valueNow != valueOld ? Colors.transparent : Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
      onTap: () async {
        final chartData = ChartData(
          title: 'Player $label History',
          yValues: [lisStatsHistoryAll],
          typeXAxis: XAxisType.weekHistory,
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ChartDialogBox(chartData: chartData);
          },
        );
      },
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
