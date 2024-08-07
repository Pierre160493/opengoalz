part of 'player.dart';

extension PlayerWidgetsHelper on Player {
  Widget getPlayerNames(BuildContext context) {
    /// Check if the player belongs to the currently connected user
    bool isMine = Provider.of<SessionProvider>(context)
        .user!
        .players
        .map((player) => player.id)
        .toList()
        .contains(id);

    /// Text widget of the player name
    Text text = Text(
      '${firstName[0]}.${lastName.toUpperCase()}',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isMine ? colorIsMine : null,
      ),

      overflow: TextOverflow.fade, // or TextOverflow.ellipsis
      maxLines: 1,
      softWrap: false,
    );

    return Row(
      children: [Icon(getPlayerIcon()), text],
    );
  }

  /// Clickable widget of the club name
  Widget getPlayerNameClickable(BuildContext context,
      {bool isRightClub = false}) {
    return Row(
      mainAxisAlignment:
          isRightClub ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayersPage(
                  inputCriteria: {
                    'Players': [id]
                  },
                ),
              ),
            );
          },
          child: getPlayerNames(context),
        ),
      ],
    );
  }

  /// get the club name
  Widget getClubNameWidget(BuildContext context) {
    return getClubNameClickable(context, club, idClub);

    // if (idClub == null) {
    //   return Row(
    //     children: [
    //       Icon(
    //         Icons.fireplace_outlined,
    //         size: icon_size, // Adjust icon size as needed
    //         color: Colors.green, // Adjust icon color as needed
    //       ),
    //       Text(
    //         'Free Player',
    //         style: TextStyle(
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //     ],
    //   );
    // } else {
    //   return Row(
    //     children: [
    //       // Icon(
    //       //   icon_club,
    //       //   size: icon_size, // Adjust icon size as needed
    //       //   color: Colors.green, // Adjust icon color as needed
    //       // ),
    //       if (club == null)
    //         Text(
    //           'ERROR: Club of this player wasn\'t found',
    //           style: TextStyle(
    //             fontWeight: FontWeight.bold,
    //           ),
    //         )
    //       else
    //         club!.getClubNameClickable(context),
    //     ],
    //   );
    // }
  }

  /// get the username of the player
  // Widget getUserNameWidget() {
  //   if (userName == null) {
  //     return Row(
  //       children: [
  //         Icon(
  //           Icons.error,
  //         ),
  //         Text(
  //           'No User',
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  //   return Row(
  //     children: [
  //       Icon(
  //         Icons.android_outlined,
  //         color: Colors.green, // Adjust icon color as needed
  //       ),
  //       Text(
  //         userName!,
  //         style: TextStyle(
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  /// Returns the status of the player (on transfer list, being fired, injured, etc...)
  Widget getStatusRow() {
    DateTime currentDate = DateTime.now();
    return Row(
      children: [
        if (dateSell != null)
          Stack(
            children: [
              const Icon(
                Icons.monetization_on,
                color: Colors.green,
                size: 30,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Text(
                  dateSell!
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
        if (dateFiring != null)
          Stack(
            children: [
              const Icon(
                Icons.exit_to_app,
                color: Colors.red,
                size: 30,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Text(
                  dateFiring!
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
        if (dateEndInjury != null)
          Stack(
            children: [
              const Icon(
                Icons.local_hospital,
                color: Colors.red,
                size: 30,
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 48,
                    child: Icon(
                      getPlayerIcon(),
                      size: 90,
                    ),
                  ),
                  SizedBox(
                    width: 6,
                  ), // Add some space between the avatar and the text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     getAgeWidget(),
                      //     getCountryNameWidget(context, idCountry),
                      //   ],
                      // ),
                      getAgeWidget(),
                      getCountryNameWidget(context, idCountry),
                      getExpansesWidget(context),
                      getAvgStatsWidget(),
                      getClubNameWidget(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 6.0),
        if (transferBids.length > 0 && dateSell!.isAfter(DateTime.now()))
          playerTransferWidget(context),
        if (dateEndInjury != null) getInjuryWidget(),
        if (dateFiring != null) getFiringRow(),
      ],
    );
  }

  Widget getFiringRow() {
    return Row(
      children: [
        Icon(Icons.exit_to_app, color: Colors.green),
        StreamBuilder<int>(
          stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
          builder: (context, snapshot) {
            final remainingTime = dateFiring!.difference(DateTime.now());
            final daysLeft = remainingTime.inDays;
            final hoursLeft = remainingTime.inHours.remainder(24);
            final minutesLeft = remainingTime.inMinutes.remainder(60);
            final secondsLeft = remainingTime.inSeconds.remainder(60);

            return RichText(
              text: TextSpan(
                text: ' Will be fired in: ',
                style: const TextStyle(),
                children: [
                  if (daysLeft > 0) // Conditionally include days left
                    TextSpan(
                      text: '$daysLeft d, ',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  TextSpan(
                    text: '$hoursLeft h, $minutesLeft m, $secondsLeft s',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  static const double icon_size = 30.0;

  Widget getAgeWidget() {
    return Row(
      children: [
        Icon(
          Icons.cake_outlined,
          size: icon_size, // Adjust icon size as needed
          color: Colors.green, // Adjust icon color as needed
        ),
        Text(
          ' ${age.truncate()}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(' years, '),
        Text(
          ((age - age.truncate()) * (7 * 14 / multiverseSpeed))
              .floor()
              .toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(' days '),
      ],
    );
  }

  Widget getExpansesWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        showPlayerExpansesHistory(context);
      },
      child: Row(
        children: [
          Icon(
            iconMoney,
            size: icon_size, // Adjust icon size as needed
            color: Colors.green, // Adjust icon color as needed
          ),
          Text(
            ' ${expanses.toString()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(' / week'),
        ],
      ),
    );
  }

  Widget getAvgStatsWidget() {
    return Row(
      children: [
        Icon(
          Icons.query_stats_outlined,
          size: icon_size, // Adjust icon size as needed
          color: Colors.green, // Adjust icon color as needed
        ),
        Text(
          ' ${stats_average.toStringAsFixed(1)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(' Average Stats')
      ],
    );
  }

  Widget getInjuryWidget() {
    return Row(
      children: [
        Icon(Icons.personal_injury_outlined,
            size: icon_size, color: Colors.red), // Adjust icon size and color
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

  Widget getStatLinearWidget(String label, double value) {
    return Row(
      children: [
        Container(
          width: 100, // Fixed width for the label
          child: Text(label),
        ),
        SizedBox(
          width: 120,
          height: 20, // Height of the bar
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(10), // Rounded corners for the bar
            child: LinearProgressIndicator(
              value: value / 100, // Assuming value ranges from 0 to 100
              backgroundColor: Colors.grey[300], // Background color of the bar
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.green, // Color of the filled portion of the bar
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getStaminaWidget() {
    return Row(
      children: [
        Text('Stamina'),
        SizedBox(
          width: 200, // Adjust the width of the bar as needed
          height: 20, // Height of the bar
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(10), // Rounded corners for the bar
            child: LinearProgressIndicator(
              value: stamina /
                  100, // Assuming widget.player.defense ranges from 0 to 100
              backgroundColor: Colors.grey[300], // Background color of the bar
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green), // Color of the filled portion of the bar
            ),
          ),
        ),
      ],
    );
  }

  Widget getFormWidget() {
    return Row(
      children: [
        Text('Form'),
        SizedBox(
          width: 200, // Adjust the width of the bar as needed
          height: 20, // Height of the bar
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(10), // Rounded corners for the bar
            child: LinearProgressIndicator(
              value: form /
                  100, // Assuming widget.player.defense ranges from 0 to 100
              backgroundColor: Colors.grey[300], // Background color of the bar
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green), // Color of the filled portion of the bar
            ),
          ),
        ),
      ],
    );
  }

  Widget getExperienceWidget() {
    return Row(
      children: [
        Text('Experience'),
        SizedBox(
          width: 200, // Adjust the width of the bar as needed
          height: 20, // Height of the bar
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(10), // Rounded corners for the bar
            child: LinearProgressIndicator(
              value: experience /
                  100, // Assuming widget.player.defense ranges from 0 to 100
              backgroundColor: Colors.grey[300], // Background color of the bar
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green), // Color of the filled portion of the bar
            ),
          ),
        ),
      ],
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
