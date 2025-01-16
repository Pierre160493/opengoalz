part of 'league.dart';

extension LeagueGamesTab on League {
  Widget leagueGamesTab(BuildContext context) {
    final List<Game> gamesCurrent = [];
    final List<Game> gamesIncoming = [];
    final List<Game> gamesPlayed = [];

    for (Game game in games) {
      if (game.isPlaying == true) {
        gamesCurrent.add(game);
      } else if (game.isPlaying == false) {
        gamesPlayed.add(game);
      } else {
        gamesIncoming.add(game);
      }
    }

    return DefaultTabController(
      length: gamesCurrent.length == 0 ? 2 : 3, // Number of tabs
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(
                  icon: iconGamePlayed,
                  text: 'Played (${gamesPlayed.length})'),
              if (gamesCurrent.length > 0)
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
                if (gamesCurrent.length > 0) buildGameListByRound(gamesCurrent),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final Game game = games[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(GamePage.route(game.id, 0));
                },
                // child: _buildGameDescription(game),
                child: game.getGamePresentation(context),
              );
            },
            // leading: Text('test')
          ),
        ),
      ],
    );
  }
}
