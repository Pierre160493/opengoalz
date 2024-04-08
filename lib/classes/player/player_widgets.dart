part of 'player.dart';

extension PlayerWidgets on Player {
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

  Widget getClubNameWidget() {
    print(id_club);
    if (id_club == null) {
      return Text(
        'Free Player',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return StreamBuilder<Club>(
        stream: supabase
            .from('view_clubs')
            .stream(primaryKey: ['id'])
            .eq('id_club', id_club!)
            .map((maps) => maps
                .map((map) => Club.fromMap(
                    map: map, myUserId: supabase.auth.currentUser!.id))
                .first),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final club = snapshot.data!;
            return Row(
              children: [
                Icon(
                  Icons.real_estate_agent_outlined,
                  size: icon_size, // Adjust icon size as needed
                  color: Colors.grey, // Adjust icon color as needed
                ),
                Text(
                  ' ${club.club_name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(' Club')
              ],
            );
          }
        },
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
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final countries = snapshot.data!;
          if (countries.isEmpty) {
            return Text('Country not found');
          } else if (countries.length > 1) {
            return Text('Multiple countries found');
          }
          return Row(
            children: [
              Icon(
                Icons.real_estate_agent_outlined,
                size: 16.0, // Adjust icon size as needed
                color: Colors.grey, // Adjust icon color as needed
              ),
              Text(
                ' ${countries.first['name']}',
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
