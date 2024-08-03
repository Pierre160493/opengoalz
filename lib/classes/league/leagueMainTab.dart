part of 'league.dart';

extension LeagueMainTab on League {
  Widget leagueMainTab(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 6),

        /// Other leagues selection widget
        otherLeaguesSelectionWidget(context),

        /// Rankings
        Container(
          margin: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  height: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Rankings',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  height: 1,
                ),
              ),
            ],
          ),
        ),

        /// Rankings
        Expanded(
          child: ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: index == 0
                      ? Colors.yellow
                      : index == 1
                          ? Colors.grey
                          : index == 2
                              ? Colors.amber
                              : Colors.blue, // Set the background color
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                title: club.getClubName(context),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          // Icons.checklist,
                          Icons.emoji_events,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          club.victories.toString(),
                          style: TextStyle(
                            color: Colors.green, // Set the text color to green
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                        ),
                        Text(' / '),
                        Text(
                          club.draws.toString(),
                          style: TextStyle(
                            color: Colors.grey, // Set the text color to green
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                        ),
                        Text(' / '),
                        Text(
                          club.defeats.toString(),
                          style: TextStyle(
                            color: Colors.red, // Set the text color to green
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          club.goalsScored - club.goalsTaken > 0 ? '+' : '',
                          style: TextStyle(
                            color: Colors.grey, // Set the text color to green
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                        ),
                        Text(
                          (club.goalsScored - club.goalsTaken).toString(),
                          style: TextStyle(
                            color: Colors.grey, // Set the text color to green
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                        ),
                        Text(' ( '),
                        Text(
                          club.goalsScored.toString(),
                          style: TextStyle(
                            color: Colors.green, // Set the text color to green
                          ),
                        ),
                        Text(' / '),
                        Text(
                          club.goalsTaken.toString(),
                          style: TextStyle(
                            color: Colors.red, // Set the text color to green
                          ),
                        ),
                        Text(' )'),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    ClubPage.route(club.id),
                  );
                },
                trailing: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text(
                    '${club.points.toString()}',
                    style: TextStyle(color: Colors.black),
                  ),
                ), // Display the index starting from 1
              );
            },
          ),
        )
      ],
    );
  }

  Widget otherLeaguesSelectionWidget(BuildContext context) {
    return Column(
      /// Upper League
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if (idUpperLeague != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaguePage(
                        idLeague: idUpperLeague!,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('No upper league for first division leagues'),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_circle_up, // Changed the icon
                    color: idUpperLeague == null
                        ? Colors.blueGrey
                        : Colors.green, // Changed the icon color
                  ),
                  Text('Upper League'),
                  Icon(
                    Icons.arrow_circle_up, // Changed the icon
                    color: idUpperLeague == null
                        ? Colors.blueGrey
                        : Colors.green, // Changed the icon color
                  ),
                ],
              ),
            ),
          ],
        ),

        /// Opposite and same level league button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Same level league button (left)
            Container(
              // width: 160,
              child: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      if (level == 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'No same level league for first division leagues'),
                          ),
                        );
                      } else {
                        int leagueNumber = number == 1
                            ? (pow(2, level - 1)).toInt()
                            : number - 1;
                        try {
                          final response = await supabase
                              .from('leagues')
                              .select('id')
                              .eq('multiverse_speed', multiverseSpeed)
                              .eq('season_number', seasonNumber)
                              .eq('continent', continent)
                              .eq('level', level)
                              .eq('number', leagueNumber)
                              .limit(1)
                              .single();

                          if (response['error'] != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error fetching league: ${response['error']['message']}'),
                              ),
                            );
                          } else if (response['id'] != null) {
                            print(response['id']);
                            final idLowerLeague = response['id'];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaguePage(
                                  idLeague: idLowerLeague,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('No lower league found'),
                              ),
                            );
                          }
                        } on PostgrestException catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error fetching league: ${error.message}'),
                            ),
                          );
                        }
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                            'Left (${number - 1 == 0 ? pow(2, level - 1) : number - 1}/${pow(2, level - 1)})'),
                        Icon(
                          Icons.arrow_circle_left, // Changed the icon
                          color: level == 1
                              ? Colors.blueGrey
                              : Colors.green, // Changed the icon color
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Opposite league button
            InkWell(
              onTap: () {
                if (level > 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaguePage(
                        idLeague: -id,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('No opposite league for first division leagues'),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.compare_arrows, // Changed the icon
                    color: level == 1
                        ? Colors.blueGrey
                        : Colors.green, // Changed the icon color
                  ),
                  Text('Opposite'),
                  Icon(
                    Icons.compare_arrows, // Changed the icon
                    color: level == 1
                        ? Colors.blueGrey
                        : Colors.green, // Changed the icon color
                  ),
                ],
              ),
            ),

            /// Same level league button (right)
            Container(
              // width: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () async {
                      if (level == 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'No same level league for first division leagues'),
                          ),
                        );
                      } else {
                        int leagueNumber =
                            number == pow(2, level - 1) ? 1 : number + 1;
                        try {
                          final response = await supabase
                              .from('leagues')
                              .select('id')
                              .eq('multiverse_speed', multiverseSpeed)
                              .eq('season_number', seasonNumber)
                              .eq('continent', continent)
                              .eq('level', level)
                              .eq('number', leagueNumber)
                              .limit(1)
                              .single();

                          if (response['error'] != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error fetching league: ${response['error']['message']}'),
                              ),
                            );
                          } else if (response['id'] != null) {
                            print(response['id']);
                            final idLowerLeague = response['id'];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaguePage(
                                  idLeague: idLowerLeague,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('No lower league found'),
                              ),
                            );
                          }
                        } on PostgrestException catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error fetching league: ${error.message}'),
                            ),
                          );
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.arrow_circle_right, // Changed the icon
                          color: level == 1
                              ? Colors.blueGrey
                              : Colors.green, // Changed the icon color
                        ),
                        const SizedBox(width: 3),
                        Text(
                            'Right (${number + 1 > pow(2, level - 1) ? 1 : number + 1}/${pow(2, level - 1)})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        /// Lower Leagues
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () async {
                try {
                  final response = await supabase
                      .from('leagues')
                      .select('id')
                      .eq('id_upper_league', id)
                      .gt('id', 0)
                      .limit(1)
                      .single();

                  if (response['error'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Error fetching league: ${response['error']['message']}'),
                      ),
                    );
                  } else if (response['id'] != null) {
                    print(response['id']);
                    final idLowerLeague = response['id'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaguePage(
                          idLeague: idLowerLeague,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('No lower league found'),
                      ),
                    );
                  }
                } on PostgrestException catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error fetching league: ${error.message}'),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Text('Lower Left'),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_circle_down, // Changed the icon
                    color: Colors.green, // Changed the icon color
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                try {
                  final response = await supabase
                      .from('leagues')
                      .select('id')
                      .eq('id_upper_league', id)
                      .gt('id', 0)
                      .limit(1)
                      .single();

                  if (response['error'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Error fetching league: ${response['error']['message']}'),
                      ),
                    );
                  } else if (response['id'] != null) {
                    print(response['id']);
                    final idLowerLeague = response['id'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaguePage(
                          idLeague: -idLowerLeague,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('No lower league found'),
                      ),
                    );
                  }
                } on PostgrestException catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error fetching league: ${error.message}'),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_circle_down, // Changed the icon
                    color: Colors.green, // Changed the icon color
                  ),
                  const SizedBox(width: 6),
                  Text('Lower Right'),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
