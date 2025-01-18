import 'package:flutter/material.dart';
import 'dart:async';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/class/game.dart';
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
  int _seasonNumber = 0;

  @override
  void initState() {
    super.initState();
    _gamesStream = supabase
        .from('games')
        .stream(primaryKey: ['id'])
        .inFilter('id', widget.player.idGamesPlayed)
        .order('date_start', ascending: true)
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
          _seasonNumber = games
              .map((game) => game.seasonNumber)
              .reduce((a, b) => a > b ? a : b);
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
    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              Text('Modify Season Number'),
              IconButton(
                icon: Icon(Icons.backspace),
                onPressed: () {
                  _seasonNumber = _seasonNumber - 1;
                  setState(() {});
                },
              ),
              IconButton(
                icon: Icon(Icons.backspace),
                onPressed: () {
                  _seasonNumber = _seasonNumber + 1;
                  setState(() {});
                },
              ),
            ],
          ),
          trailing: Icon(Icons.edit),
          onTap: () {
            // Add your logic to modify the season number here
          },
        ),
        Expanded(
          child: StreamBuilder(
            stream: _gamesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No games found'));
              } else {
                List<Game> games = snapshot.data!;
                return ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final Game game = games[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(GamePage.route(game.id, 0));
                      },
                      child: game.getGamePresentation(context),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
