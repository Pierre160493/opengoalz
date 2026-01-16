import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/others/getClubNameWidget.dart';
import 'package:opengoalz/models/events/event.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class LeaguePageStatsTab extends StatelessWidget {
  final League league;

  const LeaguePageStatsTab({Key? key, required this.league}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<int, int> playerGoals = {}; // Map of player IDs to goals
    Map<int, int> playerAssists = {}; // Map of player IDs to assists

    // Count the goals and assists by each player
    for (Game game in league.games.where((game) => game.dateEnd != null)) {
      for (GameEvent event in game.events
          .where((event) => event.eventType.toUpperCase() == 'GOAL')) {
        if (event.idPlayer != null) {
          playerGoals[event.idPlayer!] =
              (playerGoals[event.idPlayer!] ?? 0) + 1;
        }
        if (event.idPlayer2 != null) {
          playerAssists[event.idPlayer2!] =
              (playerAssists[event.idPlayer2!] ?? 0) + 1;
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
        .map((maps) => maps
            .map((map) => Player.fromMap(map,
                Provider.of<UserSessionProvider>(context, listen: false).user))
            .toList())
        .switchMap((List<Player> players) {
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .inFilter(
                  'id',
                  players
                      .where((player) => player.idClub != null)
                      .map((player) => player.idClub)
                      .toSet()
                      .toList()
                      .cast<Object>())
              .map((maps) => maps
                  .map((map) => Club.fromMap(
                      map,
                      Provider.of<UserSessionProvider>(context, listen: false)
                          .user))
                  .toList())
              .map((List<Club> clubs) {
                return players.map((player) {
                  // player.club =
                  //     clubs.firstWhere((club) => club.id == player.idClub);
                  return player;
                }).toList();
              });
        });

    return StreamBuilder<List<Player>>(
        stream: _playersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCircularAndText('Loading top scorers and assists');
          } else if (snapshot.hasError) {
            return ErrorWithBackButton(errorMessage: snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return ErrorWithBackButton(errorMessage: 'No data available');
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
                        buildTabWithIcon(
                            icon: Icons.sports_soccer, text: 'Top Scorers'),
                        buildTabWithIcon(
                            icon: Icons.sports_kabaddi, text: 'Assists'),
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
      return ErrorWithBackButton(errorMessage: 'No data available');
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
              style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSizeLarge,
                  fontWeight: FontWeight.bold),
            ),
          ),

          /// Display player name
          title: players[entry.key]!.getPlayerNameClickable(context),

          /// Display club name and username
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClubNameClickable(idClub: players[entry.key]!.idClub!),
              if (players[entry.key]!.userName != null)
                getUserNameClickable(context,
                    userName: players[entry.key]!.userName!),
            ],
          ),

          /// Show number of goals
          trailing: CircleAvatar(
            backgroundColor: Colors.blueGrey, // Set the background color,
            child: Text(
              '${entry.value}',
              style: TextStyle(
                  fontSize: fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        );
      },
    );
  }
}
