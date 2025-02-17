import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/gameCard.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/pages/teamCompPage.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';

import '../constants.dart';

class GamesPage extends StatefulWidget {
  final int idClub;
  final int? seasonNumber;
  const GamesPage({Key? key, required this.idClub, this.seasonNumber = null})
      : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute(
      builder: (context) => GamesPage(idClub: idClub),
    );
  }

  @override
  State<GamesPage> createState() => _HomePageState();
}

class _HomePageState extends State<GamesPage> {
  late final StreamController<Club> _clubStreamController;
  late Stream<Club> _clubStream;
  int?
      _seasonNumberForStream; // Season number of the games of the club to display
  late int
      _seasonNumberDisplayed; // Season number of the games of the club to display

  @override
  void initState() {
    super.initState();

    _seasonNumberForStream = widget.seasonNumber;
    _clubStreamController = StreamController<Club>();
    _clubStream = _clubStreamController.stream;

    _loadClubGames();
  }

  void _loadClubGames() {
    supabase
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idClub)
        .map((maps) => Club.fromMap(maps.first))

        /// Fetch the games
        .switchMap((Club club) {
          /// By default fetch the games using the club.idGames list
          if (_seasonNumberForStream == null) {
            return supabase
                .from('games')
                .stream(primaryKey: ['id'])
                .inFilter('id', club.idGames)
                .map((maps) => maps
                    .map((map) => Game.fromMap(map, widget.idClub))
                    .toList())
                .map((List<Game> games) {
                  if (games.isEmpty) {
                    throw Exception(
                        'No games found for club with id ${widget.idClub} for the current season');
                  }
                  club.games = games;
                  _seasonNumberDisplayed = club.games.first.seasonNumber;
                  return club;
                });
          } else {
            _seasonNumberDisplayed = _seasonNumberForStream!;

            /// Otherwise fetch the games using the club.id
            return supabase
                .from('games')
                .stream(primaryKey: ['id'])
                .eq('id_club_right', club.id)
                .map((maps) => maps
                    .map((map) => Game.fromMap(map, widget.idClub))
                    .toList())
                .map((games) {
                  games
                      .where(
                          (game) => game.seasonNumber == _seasonNumberForStream)
                      .forEach((game) {
                    club.games.add(game);
                  });
                  return club;
                })
                .switchMap((Club club) {
                  return supabase
                      .from('games')
                      .stream(primaryKey: ['id'])
                      .eq('id_club_right', club.id)
                      .map((maps) => maps
                          .map((map) => Game.fromMap(map, widget.idClub))
                          .toList())
                      .map((games) {
                        games
                            .where((game) =>
                                game.seasonNumber == _seasonNumberForStream)
                            .forEach((game) {
                          club.games.add(game);
                        });
                        return club;
                      });
                });
          }
        })
        .switchMap((Club club) {
          return supabase
              .from('games_description')
              .stream(primaryKey: ['id'])
              .inFilter(
                  'id',
                  club.games
                      .map((game) => game.idDescription)
                      .map((id) => id)
                      .toSet()
                      .toList())
              .map((maps) => maps)
              .map((map) {
                for (Game game in club.games) {
                  game.description = map.firstWhere(
                      (map) => map['id'] == game.idDescription)['description'];
                }
                return club;
              });
        })

        /// Fetch the clubs for the games
        .switchMap((Club club) {
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .inFilter(
                  'id',
                  [
                    club.games.map((game) => game.idClubRight),
                    club.games.map((game) => game.idClubLeft)
                  ]
                      .expand((x) => x)
                      .where((id) => id != null)
                      .map((id) => id!)
                      .toSet()
                      .toList())
              .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
              .map((clubs) {
                for (var game in club.games) {
                  game.rightClub =
                      clubs.firstWhere((club) => club.id == game.idClubRight);
                  game.leftClub =
                      clubs.firstWhere((club) => club.id == game.idClubLeft);
                }
                return club;
              });
        })
        .switchMap((Club club) {
          return supabase
              .from('games_teamcomp')
              .stream(primaryKey: ['id'])
              .eq('id_club', club.id)
              .map((maps) => maps.map((map) => TeamComp.fromMap(map)).toList())
              .map((List<TeamComp> teamComps) {
                for (TeamComp teamcomp in teamComps.where((teamcomp) =>
                    teamcomp.seasonNumber == _seasonNumberDisplayed)) {
                  // If no game exists for the week of the teamcomp
                  if (!club.games
                      .any((game) => game.weekNumber == teamcomp.weekNumber)) {
                    club.teamComps.add(teamcomp);
                  }
                }
                return club;
              });
        })
        .listen((club) {
          _clubStreamController.add(club);
        });
  }

  @override
  void dispose() {
    _clubStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Club>(
        stream: _clubStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCircularAndText('Loading games...');
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            Club club = snapshot.data!;

            final List<Game> gamesCurrent = [];
            final List<Game> gamesIncoming = [];
            final List<Game> gamesPlayed = [];

            /// Loop through games to store them in the right list
            for (Game game in club.games) {
              /// Games for this season

              // Game is not played yet
              if (game.isPlaying == null) {
                gamesIncoming.add(game);
              } else if (game.isPlaying!) {
                gamesCurrent.add(game);
              } else if (game.isPlaying! == false) {
                gamesPlayed.add(game);
              } else {
                throw Exception('Game ${game.id} has no isPlaying value');
              }

              gamesIncoming.sort((a, b) => a.dateStart.compareTo(b.dateStart));
              gamesCurrent.sort((a, b) => a.dateStart.compareTo(b.dateStart));
              gamesPlayed.sort((a, b) => b.dateStart.compareTo(a.dateStart));
            }
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    Row(
                      children: [
                        club.getClubNameClickable(context),
                        Text(' Games for season $_seasonNumberDisplayed'),
                      ],
                    ),
                  ],
                ),
                leading: goBackIconButton(context),
                actions: [
                  if (_seasonNumberDisplayed > 1)
                    IconButton(
                      tooltip: 'Previous season',
                      icon: Icon(Icons.remove, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          _seasonNumberForStream = _seasonNumberDisplayed - 1;
                          _loadClubGames();
                        });
                      },
                    ),
                  IconButton(
                    tooltip: 'Reset to current season',
                    icon: Icon(Icons.refresh, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        _seasonNumberForStream = null;
                        _loadClubGames();
                      });
                    },
                  ),
                  IconButton(
                    tooltip: 'Next season',
                    icon: Icon(Icons.add, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        _seasonNumberForStream = _seasonNumberDisplayed + 1;
                        _loadClubGames();
                      });
                    },
                  ),
                ],
              ),
              body: MaxWidthContainer(
                child: DefaultTabController(
                  length: gamesCurrent.length == 0 ? 2 : 3, // Number of tabs
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Level 1 Tabs
                      TabBar(
                        tabs: [
                          /// Played games title
                          buildTabWithIcon(
                              icon: iconGamePlayed,
                              text: 'Played (${gamesPlayed.length})'),

                          /// Current games title
                          if (gamesCurrent.length > 0)
                            buildTabWithIcon(
                                icon: iconGameIsPlaying,
                                text: 'Current (${gamesCurrent.length})'),

                          /// Incoming games title
                          buildTabWithIcon(
                              icon: iconGameNotPlayed,
                              text:
                                  'Incoming (${gamesIncoming.length}+${club.teamComps.length})'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            /// Played games
                            _buildGameList(gamesPlayed),

                            /// Current games (if exists)
                            if (gamesCurrent.length > 0)
                              _buildGameList(gamesCurrent),

                            /// Incoming games
                            // _buildGameList(gamesIncoming),
                            DefaultTabController(
                              length: 2, // Number of tabs
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TabBar(
                                    tabs: [
                                      // Current season organized games
                                      buildTabWithIcon(
                                          icon: Icons.calendar_month,
                                          text:
                                              'Planned (${gamesIncoming.length})'),

                                      // Current season unorganized games yet
                                      buildTabWithIcon(
                                          icon: Icons.edit_calendar,
                                          text:
                                              'Unplanned (${club.teamComps.length})'),
                                    ],
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: [
                                        _buildGameList(gamesIncoming),
                                        _buildTeamCompList(club),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }

  Widget _buildGameList(List<Game> games) {
    if (games.isEmpty) {
      return const Center(
        child: Text('No games found'),
      );
    }
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
                  Navigator.of(context)
                      .push(GamePage.route(game.id, widget.idClub));
                },
                child: getGameCardWidget(context, game),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCompList(Club club) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: club.teamComps.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TeamCompPage(
                        idClub: club.id,
                        seasonNumber: club.teamComps[index].seasonNumber,
                        weekNumber: club.teamComps[index].weekNumber,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: Icon(
                    Icons.sports_soccer_outlined,
                    size: 36,
                    color: Colors.blueGrey,
                  ),
                  title: Text('Week ${club.teamComps[index].weekNumber}'),
                  subtitle: Row(
                    children: [
                      const Icon(
                        Icons.description,
                        color: Colors.blueGrey,
                      ),
                      Expanded(
                        child: Text(
                          club.teamComps[index].weekNumber <= 10
                              ? 'Round ${club.teamComps[index].weekNumber} of the main league of season ${club.teamComps[index].seasonNumber}'
                              : 'Game ${club.teamComps[index].weekNumber - 10} of the interseason games of season ${club.teamComps[index].seasonNumber}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  shape: shapePersoRoundedBorder(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
