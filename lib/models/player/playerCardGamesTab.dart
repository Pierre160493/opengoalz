import 'package:flutter/material.dart';
import 'dart:async';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/game/gameCard.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/pages/game_page.dart';
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
        .from('games')
        .stream(primaryKey: ['id'])
        .inFilter('id', widget.player.idGamesPlayed)
        .order('date_start', ascending: false)
        .map((maps) => maps.map((map) => Game.fromMap(map, null)).toList())
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
              .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
              .map((List<Club> clubs) {
                for (Game game in games) {
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
                            .map((id) => id)
                            .toSet()
                            .toList())
                    .map((maps) => maps)
                    .map((map) {
                      for (Game game in games) {
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No games found'));
        } else {
          List<Game> games = snapshot.data!;
          List<Game> filteredGames = games
              .where((game) => game.seasonNumber == _selectedSeasonNumber)
              .toList();
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
                  children: [
                    Icon(Icons.sports_soccer,
                        color: Colors.green, size: iconSizeSmall),
                    Text(' Games played: '),
                    Text(filteredGames.length.toString(),
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                shape: shapePersoRoundedBorder(Colors.green, 3),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredGames.length,
                  itemBuilder: (context, index) {
                    final Game game = filteredGames[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(GamePage.route(game.id, 0));
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
