import 'package:flutter/material.dart';
import 'dart:async';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/game/gameCard.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/playerStatsBest.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'package:rxdart/rxdart.dart';

class PlayerGamesTab extends StatefulWidget {
  final Player player;

  PlayerGamesTab(this.player);

  @override
  _PlayerGamesTabState createState() => _PlayerGamesTabState();
}

class _PlayerGamesTabState extends State<PlayerGamesTab> {
  late Stream<List<Game>> _gamesStream;
  late StreamSubscription _gamesSubscription;
  int? _selectedSeasonNumber;
  int? _maxSeasonNumber;

  @override
  void initState() {
    super.initState();
    _gamesStream = supabase
        .from('game_player_stats_best')
        .stream(primaryKey: ['id'])
        .eq('id_player', widget.player.id)
        .map((maps) =>
            maps.map((map) => GamePlayerStatsBest.fromMap(map)).toList())
        .switchMap((List<GamePlayerStatsBest> stats) {
          List<int> gameIds = stats.map((stat) => stat.idGame).toList();
          return supabase
              .from('games')
              .stream(primaryKey: ['id'])
              .inFilter('id', gameIds)
              .order('date_start', ascending: true)
              .map(
                  (maps) => maps.map((map) => Game.fromMap(map, null)).toList())
              .map((List<Game> games) {
                for (var game in games) {
                  game.playerGameBestStats = widget.player;
                  game.playerGameBestStats!.gamePlayerStatsBest = stats.firstWhere(
                      (stat) => stat.idGame == game.id,
                      orElse: () => throw Exception(
                          'GamePlayerStatsBest not found for game with id: ${game.id}'));
                  game.isLeftClubSelected = game.playerGameBestStats!
                      .gamePlayerStatsBest!.isLeftClubPlayer;
                }
                return games;
              })
              .switchMap((List<Game> games) {
                List<int> clubsIds = games
                    .map((game) => [game.idClubLeft, game.idClubRight])
                    .expand((element) => element)
                    .where((element) => element != null)
                    .toSet()
                    .toList()
                    .cast<int>();
                return supabase
                    .from('clubs')
                    .stream(primaryKey: ['id'])
                    .inFilter('id', clubsIds)
                    .map(
                        (maps) => maps.map((map) => Club.fromMap(map)).toList())
                    .map((List<Club> clubs) {
                      for (var game in games) {
                        if (game.idClubLeft != null) {
                          game.leftClub = clubs.firstWhere(
                            (club) => club.id == game.idClubLeft,
                            orElse: () => throw Exception(
                                'DATABASE ERROR: Club not found for the left club with id: ${game.idClubLeft} for the game with id: ${game.id}'),
                          );
                        }
                        if (game.idClubRight != null) {
                          game.rightClub = clubs.firstWhere(
                              (club) => club.id == game.idClubRight,
                              orElse: () => throw Exception(
                                  'DATABASE ERROR: Club not found for the right club with id: ${game.idClubRight} for the game with id: ${game.id}'));
                        }
                      }
                      return games;
                    })
                    .switchMap((List<Game> games) {
                      return supabase
                          .from('games_description')
                          .stream(primaryKey: ['id'])
                          .inFilter(
                              'id',
                              games
                                  .map((game) => game.idDescription)
                                  .toSet()
                                  .toList())
                          .map((maps) => maps)
                          .map((map) {
                            for (var game in games) {
                              game.description = map.firstWhere(
                                      (map) => map['id'] == game.idDescription,
                                      orElse: () => throw StateError(
                                          'No description found for game with id ${game.idDescription}'))[
                                  'description'];
                            }
                            return games;
                          });
                    });
              });
        });

    _gamesSubscription = _gamesStream.listen((games) {
      if (mounted) {
        setState(() {
          _maxSeasonNumber = games
              .map((game) => game.seasonNumber)
              .reduce((a, b) => a > b ? a : b);
          if (_selectedSeasonNumber == null) {
            _selectedSeasonNumber = _maxSeasonNumber;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _gamesSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _gamesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingCircularAndText('Loading Games Played...');
        } else if (snapshot.hasError) {
          return ErrorWithBackButton(errorMessage: snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return ErrorWithBackButton(errorMessage: 'No games found');
        } else {
          List<Game> games = snapshot.data!;
          List<Game> filteredGames = games
              .where((game) => game.seasonNumber == _selectedSeasonNumber)
              .toList();
          Game? bestSeasonGame = filteredGames.isNotEmpty
              ? filteredGames.reduce((a, b) =>
                  a.playerGameBestStats!.gamePlayerStatsBest!.sumWeights >
                          b.playerGameBestStats!.gamePlayerStatsBest!.sumWeights
                      ? a
                      : b)
              : null;
          return Column(
            children: [
              ListTile(
                leading: Icon(Icons.calendar_today,
                    color: Colors.green, size: iconSizeMedium),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Season Number: '),
                        Text(
                          _selectedSeasonNumber.toString(),
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove,
                              color: _selectedSeasonNumber == 0
                                  ? Colors.red
                                  : Colors.green),
                          onPressed: _selectedSeasonNumber == 0
                              ? null
                              : () {
                                  _selectedSeasonNumber =
                                      _selectedSeasonNumber! - 1;
                                  setState(() {});
                                },
                        ),
                        IconButton(
                          icon: Icon(Icons.add,
                              color: _selectedSeasonNumber == _maxSeasonNumber
                                  ? Colors.red
                                  : Colors.green),
                          onPressed: _selectedSeasonNumber == _maxSeasonNumber
                              ? null
                              : () {
                                  _selectedSeasonNumber =
                                      _selectedSeasonNumber! + 1;
                                  setState(() {});
                                },
                        ),
                      ],
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sports_soccer,
                            color: Colors.green, size: iconSizeSmall),
                        Text(' Games played: '),
                        Text(filteredGames.length.toString(),
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    bestSeasonGame == null
                        ? Text('No Games played this season')
                        : Row(
                            children: [
                              Text(' Best season game: '),
                              InkWell(
                                child: Text(
                                  'Weight: ' +
                                      bestSeasonGame.playerGameBestStats!
                                          .gamePlayerStatsBest!.sumWeights
                                          .toString(),
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      final chartData = ChartData(
                                        title: 'Game Weights Evolution',
                                        yValues: [
                                          games
                                              .map((game) => game
                                                  .playerGameBestStats!
                                                  .gamePlayerStatsBest!
                                                  .sumWeights)
                                              .toList(),
                                        ],
                                        typeXAxis: XAxisType.weekHistory,
                                      );

                                      return ChartDialogBox(
                                          chartData: chartData);
                                    },
                                  );
                                },
                              ),
                              InkWell(
                                child: Row(
                                  children: [
                                    Icon(Icons.stars,
                                        color: Colors.yellow,
                                        size: iconSizeSmall),
                                    Text(
                                      bestSeasonGame.playerGameBestStats!
                                          .gamePlayerStatsBest!.stars
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.yellow,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      final chartData = ChartData(
                                        title: 'Stars Evolution',
                                        yValues: [
                                          games
                                              .map((game) => game
                                                  .playerGameBestStats!
                                                  .gamePlayerStatsBest!
                                                  .stars)
                                              .toList(),
                                        ],
                                        typeXAxis: XAxisType.weekHistory,
                                      );

                                      return ChartDialogBox(
                                          chartData: chartData);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                  ],
                ),
                shape: shapePersoRoundedBorder(Colors.green, 3),
              ),
              Expanded(
                child: filteredGames.isEmpty
                    ? ErrorWithBackButton(
                        errorMessage: 'No games available for this season')
                    : ListView.builder(
                        itemCount: filteredGames.length,
                        itemBuilder: (context, index) {
                          final Game game = filteredGames[index];
                          return InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .push(GamePage.route(game.id, 0));
                            },
                            child: getGameCardWidget(context, game),
                          );
                        },
                      ),
              ),
            ],
          );
        }
      },
    );
  }
}
