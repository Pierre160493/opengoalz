part of 'player.dart';

extension PlayerWidgetsHelper on Player {
  /// Returns the status of the player (on transfer list, being fired, injured, etc...)
  Widget getStatusRow() {
    DateTime currentDate = DateTime.now();
    return Row(
      children: [
        if (date_sell != null)
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
                  date_sell!
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
        if (date_firing != null)
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
                  date_firing!
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
        if (date_end_injury != null)
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
                  date_end_injury!
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
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 48,
                child: Icon(
                  Icons.person_pin_outlined,
                  size: 90,
                ),
              ),
              SizedBox(
                width: 8,
              ), // Add some space between the avatar and the text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getAgeWidget(),
                  getCountryNameWidget(id_country),
                  getAvgStatsWidget(),
                  getClubNameWidget(context),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getFiringRow() {
    return Row(
      children: [
        StreamBuilder<int>(
          stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
          builder: (context, snapshot) {
            final remainingTime = date_firing!.difference(DateTime.now());
            final daysLeft = remainingTime.inDays;
            final hoursLeft = remainingTime.inHours.remainder(24);
            final minutesLeft = remainingTime.inMinutes.remainder(60);
            final secondsLeft = remainingTime.inSeconds.remainder(60);

            return RichText(
              text: TextSpan(
                text: 'Will be fired in: ',
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

  static const double icon_size = 24.0;

  Widget getAgeWidget() {
    return Row(
      children: [
        Icon(
          Icons.cake_outlined,
          size: icon_size, // Adjust icon size as needed
          color: Colors.grey, // Adjust icon color as needed
        ),
        Text(
          ' ${age.truncate()}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(' years, '),
        Text(
          ((age - age.truncate()) * 112).floor().toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(' days '),
      ],
    );
  }

  Widget getAvgStatsWidget() {
    return Row(
      children: [
        Icon(
          Icons.query_stats_outlined,
          size: icon_size, // Adjust icon size as needed
          color: Colors.grey, // Adjust icon color as needed
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

  Widget getClubNameWidget(BuildContext context) {
    if (id_club == null) {
      return Row(
        children: [
          Icon(
            Icons.fireplace_outlined,
            size: icon_size, // Adjust icon size as needed
            color: Colors.grey, // Adjust icon color as needed
          ),
          Text(
            'Free Player',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(
            icon_club,
            size: icon_size, // Adjust icon size as needed
            color: Colors.grey, // Adjust icon color as needed
          ),
          if (club == null)
            Text(
              'ERROR: Club of this player wasn\'t found',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )
          else
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  ClubPage.route(id_club!),
                );
              },
              child: Text(
                ' ${club!.club_name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
        ],
      );
    }
  }

  Widget getUserNameWidget() {
    return Row(
      children: [
        Icon(
          Icons.android_outlined,
          size: icon_size, // Adjust icon size as needed
          color: Colors.grey, // Adjust icon color as needed
        ),
        // Text(
        //   ' ${username}',
        //   style: TextStyle(
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
      ],
    );
  }

  Widget getInjuryWidget() {
    return Row(
      children: [
        Icon(Icons.personal_injury_outlined,
            size: icon_size, color: Colors.red), // Adjust icon size and color
        Text(
          ' ${date_end_injury!.difference(DateTime.now()).inDays.toString()}',
          style: const TextStyle(
            fontWeight: FontWeight.bold, // Remove bold font weight
            // color: Colors.red,
          ),
        ),
        Text(' days left for recovery')
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
                  Colors.blue), // Color of the filled portion of the bar
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
                  Colors.blue), // Color of the filled portion of the bar
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
                  Colors.blue), // Color of the filled portion of the bar
            ),
          ),
        ),
      ],
    );
  }

  Widget getCountryNameWidget(int? id_country) {
    if (id_country == null) {
      // Should'nt be nullable
      return Text(
        'Apatride',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return StreamBuilder<List<Map>>(
        stream: supabase
            .from('countries')
            .stream(primaryKey: ['id'])
            .eq('id', id_country)
            .map((maps) => maps
                .map((map) => {
                      'id': map['id'],
                      'name': map['name'],
                    })
                .toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Placeholder row while loading
            return Row(
              children: [
                SizedBox(
                  width: 16.0, // Same width as the icon
                  height: 16.0, // Same height as the icon
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                ),
                SizedBox(width: 4.0), // Spacing between icon and text
                SizedBox(
                  width: 100.0, // Adjust the width as needed
                  child: Text(
                    'Loading...', // Placeholder text
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey, // Placeholder text color
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('ERROR: ${snapshot.error}');
          } else {
            final countries = snapshot.data!;
            if (countries.isEmpty) {
              return Text('ERROR: Country not found');
            } else if (countries.length > 1) {
              return Text('ERROR: Multiple countries found');
            }
            // Actual row with data
            return Row(
              children: [
                Icon(
                  Icons.flag_circle_outlined,
                  size: icon_size, // Adjust icon size as needed
                  color: Colors.grey, // Adjust icon color as needed
                ),
                SizedBox(width: 4.0), // Spacing between icon and text
                Text(
                  '${countries.first['name']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }
        },
      );
    }
  }
}
