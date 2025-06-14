import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/game/game_card.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';

class LeaguePageGamesTab extends StatelessWidget {
  final League league;

  const LeaguePageGamesTab({Key? key, required this.league}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Game> gamesCurrent = [];
    final List<Game> gamesIncoming = [];
    final List<Game> gamesPlayed = [];

    for (Game game in league.games) {
      if (game.isPlaying == true) {
        gamesCurrent.add(game);
      } else if (game.isPlaying == false) {
        gamesPlayed.add(game);
      } else {
        gamesIncoming.add(game);
      }
    }

    return DefaultTabController(
      length: gamesCurrent.isEmpty ? 2 : 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(
                  icon: iconGamePlayed, text: 'Played (${gamesPlayed.length})'),
              if (gamesCurrent.isNotEmpty)
                buildTabWithIcon(
                    icon: Icons.notifications_active,
                    text: 'Current (${gamesCurrent.length})'),
              buildTabWithIcon(
                  icon: Icons.arrow_circle_right_outlined,
                  text: 'Incoming (${gamesIncoming.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                buildGameListByRound(gamesPlayed),
                if (gamesCurrent.isNotEmpty) buildGameListByRound(gamesCurrent),
                buildGameListByRound(gamesIncoming),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGameListByRound(List<Game> games) {
    // Group the games by round
    List<List<Game>> gamesByRound =
        groupBy(games, (Game game) => game.weekNumber).values.toList();
    return DefaultTabController(
      length: gamesByRound.length, // Number of tabs
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            tabs: gamesByRound
                .map((List<Game> games) => Tab(text: 'R${games[0].weekNumber}'))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              children: gamesByRound.map((List<Game> games) {
                return buildGameList(games);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGameList(List<Game> games) {
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final Game game = games[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(GamePage.route(game.id, 0));
          },
          child: GameCardWidget(game),
          // child: Text('test ${game.id}'), // Placeholder for game card widget
        );
      },
    );
  }
}
