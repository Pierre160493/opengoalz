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
    /// Check if the player belongs to the currently connected user
    bool isMine = Provider.of<SessionProvider>(context, listen: false)
        .user!
        .players
        .map((player) => player.id)
        .toList()
        .contains(id);

    return Text(
      getPlayerNameString(isSurname: isSurname),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isMine ? colorIsMine : null,
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
          // if (idClub == null)
          //   Tooltip(
          //     message: 'Free Player',
          //     child: Stack(
          //       children: [
          //         Icon(
          //           iconFreePlayer,
          //           color: Colors.green,
          //           size: iconSizeMedium,
          //         ),
          //         Positioned(
          //           top: 0,
          //           right: 0,
          //           child: Text(
          //             dateBidEnd!
          //                 .difference(currentDate)
          //                 .inDays
          //                 .toString(), // Change the number as needed
          //             style: TextStyle(
          //               color: Colors.white70,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // if (idClub != null)
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
                  Expanded(child: getAgeWidget()),
                  Expanded(child: getCountryNameWidget(context, idCountry)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: getAvgStatsWidget()),
                  Expanded(child: getExpensesWidget(context)),
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
              getAgeWidget(),
              getCountryNameWidget(context, idCountry),
              getAvgStatsWidget(),
              getExpensesWidget(context),
              if (dateBidEnd != null) PlayerCardTransferWidget(player: this),
              if (dateEndInjury != null) getInjuryWidget(),
            ],
          );
        }
      },
    );
  }

  static double iconSize = iconSizeSmall;

  Widget getAgeWidget() {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12), // Adjust border radius as needed
        side: const BorderSide(
          color: Colors.blueGrey, // Border color
        ),
      ),
      // leading: Icon(
      //   Icons.cake_outlined,
      //   size: iconSize,
      // ),
      title: Row(
        children: [
          Icon(iconAge, size: iconSize),
          getAgeStringRow(age, multiverseSpeed),
        ],
      ),
      subtitle: Row(
        children: [
          Icon(Icons.event, size: iconSize),
          formSpacer3,
          Text(DateFormat('dd MMMM yyyy').format(dateBirth),
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget getAgeWidgetSmall() {
    return Tooltip(
      message:
          // '${age.truncate().toString()} & ${((age - age.truncate()) * (7 * 14 / multiverseSpeed)).floor().toString()} days',
          '${age.truncate().toString()} & ${(age - age.truncate()).floor().toString()} days',
      child: Row(
        children: [
          Icon(iconAge, size: iconSizeSmall),
          Text(age.toStringAsFixed(1)),
        ],
      ),
      waitDuration: const Duration(seconds: 1),
    );
  }

  Widget getExpensesWidget(BuildContext context) {
    return ListTile(
      onTap: () => showPlayerExpensesHistory(context),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12), // Adjust border radius as needed
        side: const BorderSide(
          color: Colors.blueGrey, // Border color
        ),
      ),
      // leading: Icon(
      //   iconMoney,
      //   size: iconSize, // Adjust icon size as needed
      // ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                iconMoney,
                size: iconSize, // Adjust icon size as needed
              ),
              formSpacer3,
              Text(
                expensesExpected.toString(),
                // style: TextStyle(
                //   fontWeight: FontWeight.bold,
                // ),
              ),
            ],
          ),
          if (expensesMissed > 0)
            IconButton(
              tooltip: 'Past expenses not payed ${expensesMissed.toString()}',
              onPressed: () {
                if (Provider.of<SessionProvider>(context, listen: false)
                        .user!
                        .selectedClub!
                        .id ==
                    idClub) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Past expenses not payed'),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListTile(
                                title: Row(
                                  children: [
                                    Icon(iconMoney, color: Colors.red),
                                    Text(
                                      ' ${expensesMissed.toString()}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                    'Total amount of unpaid expenses',
                                    style: styleItalicBlueGrey),
                              ),
                              ListTile(
                                title: Row(
                                  children: [
                                    Icon(iconMoney, color: Colors.green),
                                    Text(
                                      ' ${Provider.of<SessionProvider>(context, listen: false).user!.selectedClub!.cash.toString()}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                subtitle: Text('Available cash',
                                    style: styleItalicBlueGrey),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Pay expenses'),
                            onPressed: () async {
                              bool isOK = await operationInDB(
                                  context, 'UPDATE', 'players',
                                  data: {'missed_expenses': 0},
                                  matchCriteria: {'id': id});
                              if (isOK) {
                                context.showSnackBar(
                                    'Successfully payed ${firstName} ${lastName} missed expenses',
                                    icon: Icon(iconSuccessfulOperation,
                                        color: Colors.green));
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  context.showSnackBarError(
                      'You are not the owner of ${firstName} ${lastName}\'s club');
                }
              },
              icon: Icon(Icons.money_off, color: Colors.red),
            ),
        ],
      ),
      subtitle: Text(
        'Expected expenses per week',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget getAvgStatsWidget() {
    return ListTile(
      shape: shapePersoRoundedBorder,
      leading: Icon(
        Icons.query_stats_outlined,
        size: iconSize,
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

  Widget getStatLinearWidget(String label, double value, BuildContext context) {
    IconData getIcon(String label) {
      switch (label) {
        case 'Motivation':
          return iconMotivation;
        case 'Stamina':
          return iconStamina;
        case 'Form':
          return iconForm;
        case 'Experience':
          return iconExperience;
        default:
          return iconBug;
      }
    }

    IconData icon = getIcon(label);

    return ListTile(
      shape: shapePersoRoundedBorder,
      leading: Icon(
        icon,
        size: iconSize,
      ),
      title: Row(
        children: [
          formSpacer6,
          Container(
            width: 100, // Fixed width for the label
            child: Text(label),
          ),
          SizedBox(
            width: 120,
            height: 24, // Height of the bar
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(10), // Rounded corners for the bar
              child: LinearProgressIndicator(
                value: value / 100, // Assuming value ranges from 0 to 100
                backgroundColor:
                    Colors.grey[300], // Background color of the bar
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green, // Color of the filled portion of the bar
                ),
              ),
            ),
          ),
        ],
      ),
      onTap: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(label),
              content: Container(
                width: double.maxFinite,
                height: 200,
                child: StreamBuilder(
                  stream: supabase
                      .from('players_history_stats')
                      .stream(primaryKey: ['id'])
                      .eq('id_player', id)
                      .order('created_at', ascending: true),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (!snapshot.hasData) {
                      return Text('Error: No data');
                    }
                    final data = snapshot.data;
                    List<double> values = data!
                        .map((e) => e[label.toLowerCase()].toDouble() as double)
                        .toList();
                    // List<DateTime> dates = data
                    //     .map((e) => DateTime.parse(e['created_at'] as String))
                    //     .toList();

                    return Container(
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: values.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value);
                              }).toList(),
                              isCurved: true,
                              barWidth: 2,
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
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
