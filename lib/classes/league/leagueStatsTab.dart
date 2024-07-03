part of 'league.dart';

extension LeagueStatsTab on League {
  Widget leagueStatsTab(BuildContext context) {
    Map<int, int> playerGoals = {}; // Map of player IDs to goals
    Map<int, int> playerAssists = {}; // Map of player IDs to assists

    // Count the goals and assists by each player
    for (Game game in games.where((game) => game.isPlayed)) {
      for (GameEvent event
          in game.events.where((event) => event.idEventType == 1)) {
        if (event.idPlayer != null) {
          playerGoals[event.idPlayer!] =
              (playerGoals[event.idPlayer!] ?? 0) + 1;
        }
        if (event.idPlayerSecond != null) {
          playerAssists[event.idPlayerSecond!] =
              (playerAssists[event.idPlayerSecond!] ?? 0) + 1;
        }
      }
    }

    // Sort the players by the number of goals and assists and keep only the top 10
    var sortedPlayerGoals = playerGoals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    sortedPlayerGoals = sortedPlayerGoals.toList();

    var sortedPlayerAssists = playerAssists.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    sortedPlayerAssists = sortedPlayerAssists.toList();

    Stream<List<Player>> _playersStream = supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .inFilter(
            'id',
            [
              sortedPlayerGoals.map((e) => e.key).toList(),
              sortedPlayerAssists.map((e) => e.key).toList()
            ].expand((x) => x).toSet().toList())
        .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
        .switchMap((List<Player> players) {
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .inFilter(
                  'id',
                  players
                      .map((player) => player.idClub)
                      .toSet()
                      .toList()
                      .cast<Object>())
              .map((maps) => maps
                  .map((map) => Club.fromMap(
                        map: map,
                        myUserId: supabase.auth.currentUser!.id,
                      ))
                  .toList())
              .map((List<Club> clubs) {
                return players.map((player) {
                  player.club =
                      clubs.firstWhere((club) => club.id_club == player.idClub);
                  return player;
                }).toList();
              });
        });

    return StreamBuilder<List<Player>>(
        stream: _playersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            Map<int, Player> players = Map.fromIterable(snapshot.data!,
                key: (player) => player.id, value: (player) => player);
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    height: 42, // Set the height as per your requirement
                    child: TabBar(
                      tabs: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports_soccer), // Add the icon here
                            SizedBox(width: 6),
                            Text('Scorers'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports_kabaddi), // Add the icon here
                            SizedBox(width: 6),
                            Text('Assists'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _displayPlayers(context, sortedPlayerGoals, players),
                        _displayPlayers(context, sortedPlayerAssists, players),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget _displayPlayers(BuildContext context,
      List<MapEntry<int, int>> sortedPlayers, Map<int, Player> players) {
    if (sortedPlayers.isEmpty) {
      return Center(child: Text('No data available'));
    }
    return ListView.builder(
      itemCount: sortedPlayers.length,
      itemBuilder: (context, index) {
        MapEntry<int, int> entry = sortedPlayers[index];
        int rank = index + 1;
        int j = index - 1;
        while (j >= 0 && entry.value == sortedPlayers[j].value) {
          rank--;
          j--;
        }
        return ListTile(
          /// Display player rank
          leading: CircleAvatar(
            backgroundColor: rank == 1
                ? Colors.yellow
                : rank == 2
                    ? Colors.grey
                    : rank == 3
                        ? Colors.amber
                        : Colors.blue,
            child: Text(
              '${rank}.',
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ),

          /// Display player name
          title: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayersPage(
                    inputCriteria: {
                      'Players': [players[entry.key]!.id]
                    },
                  ),
                ),
              );
            },
            child: Flexible(
              // Expanded(
              //   child: players[entry.key]!
              //       .getPlayerMainInformation(context),
              // ),
              child: Text(
                ' ${players[entry.key]!.firstName[0]}.${players[entry.key]!.lastName.toUpperCase()} ',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// Display club name
          subtitle: players[entry.key]!.getClubNameWidget(context),

          /// Show number of goals
          trailing: CircleAvatar(
            backgroundColor: Colors.blueGrey, // Set the background color,
            child: Text(
              '${entry.value}',
              style: TextStyle(
                  color: Colors.black, // Set the text color
                  fontSize: 24),
            ),
          ),
        );
      },
    );
  }
}
