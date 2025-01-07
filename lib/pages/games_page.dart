import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/pages/teamCompPage.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';

import '../constants.dart';

class GamesPage extends StatefulWidget {
  final int idClub;
  const GamesPage({Key? key, required this.idClub}) : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute(
      builder: (context) => GamesPage(idClub: idClub),
    );
  }

  @override
  State<GamesPage> createState() => _HomePageState();
}

class _HomePageState extends State<GamesPage> {
  late final Stream<Club> _clubStream;

  @override
  void initState() {
    super.initState();

    final startTime = DateTime.now();

    /// Get the club
    _clubStream = supabase
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idClub)
        .map((maps) => Club.fromMap(maps.first))

        /// Fetch the games where the club is left
        .switchMap((Club club) {
          return supabase
              .from('games')
              .stream(primaryKey: ['id'])
              .eq('id_club_left', club.id)
              .map((maps) =>
                  maps.map((map) => Game.fromMap(map, widget.idClub)).toList())
              .map((games) {
                games
                    .where((game) => game.seasonNumber == club.seasonNumber)
                    .forEach((game) {
                  club.games.add(game);
                });
                return club;
              });
        })

        /// Fetch the games where the club is right
        .switchMap((Club club) {
          return supabase
              .from('games')
              .stream(primaryKey: ['id'])
              .eq('id_club_right', club.id)
              .map((maps) =>
                  maps.map((map) => Game.fromMap(map, widget.idClub)).toList())
              .map((games) {
                games
                    .where((game) => game.seasonNumber == club.seasonNumber)
                    .forEach((game) {
                  club.games.add(game);
                });
                return club;
              });
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
                for (TeamComp teamcomp in teamComps.where(
                    (teamcomp) => teamcomp.seasonNumber == club.seasonNumber)) {
                  // If no game exists for the week of the teamcomp
                  if (!club.games
                      .any((game) => game.weekNumber == teamcomp.weekNumber)) {
                    club.teamComps.add(teamcomp);
                  }
                }

                // Capture the end time
                final endTime = DateTime.now();

                // Calculate the difference
                final loadTime = endTime.difference(startTime);
                print('Page loaded in ${loadTime.inMilliseconds} ms');

                return club;
              });
        });

    // _clubStream = supabase
    //     .from('clubs')
    //     .stream(primaryKey: ['id'])
    //     .eq('id', widget.idClub)
    //     .map((maps) => Club.fromMap(maps.first))
    //     .asyncMap((Club club) async {
    //       final gamesLeftFuture =
    //           supabase.from('games').select().eq('id_club_left', club.id);
    //       final gamesRightFuture =
    //           supabase.from('games').select().eq('id_club_right', club.id);
    //       final gamesDescriptionFuture = supabase
    //           .from('games_description')
    //           .select()
    //           .inFilter(
    //               'id',
    //               club.games
    //                   .map((game) => game.idDescription)
    //                   .toSet()
    //                   .toList());
    //       final clubsFuture = supabase.from('clubs').select().inFilter(
    //           'id',
    //           [
    //             ...club.games.map((game) => game.idClubRight),
    //             ...club.games.map((game) => game.idClubLeft)
    //           ].toSet().toList());
    //       final teamCompsFuture =
    //           supabase.from('games_teamcomp').select().eq('id_club', club.id);

    //       final results = await Future.wait([
    //         gamesLeftFuture,
    //         gamesRightFuture,
    //         gamesDescriptionFuture,
    //         clubsFuture,
    //         teamCompsFuture
    //       ]);

    //       final gamesLeft = (results[0] as List)
    //           .map((map) => Game.fromMap(map, widget.idClub))
    //           .toList();
    //       final gamesRight = (results[1] as List)
    //           .map((map) => Game.fromMap(map, widget.idClub))
    //           .toList();
    //       final gamesDescription = results[2] as List;
    //       final clubs =
    //           (results[3] as List).map((map) => Club.fromMap(map)).toList();
    //       final teamComps =
    //           (results[4] as List).map((map) => TeamComp.fromMap(map)).toList();

    //       club.games.addAll(gamesLeft
    //           .where((game) => game.seasonNumber == club.seasonNumber));
    //       club.games.addAll(gamesRight
    //           .where((game) => game.seasonNumber == club.seasonNumber));
    //       club.games.sort((a, b) => a.dateStart.compareTo(b.dateStart));

    //       for (Game game in club.games) {
    //         game.description = gamesDescription.firstWhere(
    //             (map) => map['id'] == game.idDescription)['description'];
    //         game.rightClub =
    //             clubs.firstWhere((club) => club.id == game.idClubRight);
    //         game.leftClub =
    //             clubs.firstWhere((club) => club.id == game.idClubLeft);
    //       }

    //       for (TeamComp teamcomp in teamComps.where(
    //           (teamcomp) => teamcomp.seasonNumber == club.seasonNumber)) {
    //         if (!club.games
    //             .any((game) => game.weekNumber == teamcomp.weekNumber)) {
    //           club.teamComps.add(teamcomp);
    //         }
    //       }

    //       // Capture the end time
    //       final endTime = DateTime.now();

    //       // Calculate the difference
    //       final loadTime = endTime.difference(startTime);
    //       print('Page loaded in ${loadTime.inMilliseconds} ms');

    //       return club;
    //     });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Club>(
        stream: _clubStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            Club club = snapshot.data!;
            if (club.games.isEmpty) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      'Empty Games Page for club with id: ${widget.idClub}'),
                ),
                drawer: const AppDrawer(),
                body: Center(
                  child:
                      Text('No games found for club with id ${widget.idClub}'),
                ),
              );
            } else {
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

                gamesIncoming
                    .sort((a, b) => a.dateStart.compareTo(b.dateStart));
                gamesCurrent.sort((a, b) => a.dateStart.compareTo(b.dateStart));
                gamesPlayed.sort((a, b) => b.dateStart.compareTo(a.dateStart));
              }
              return Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      Row(
                        children: [
                          Text('Games Page for '),
                          club.getClubNameClickable(context),
                        ],
                      ),
                      // Container(
                      //   decoration: BoxDecoration(color: Colors.white),
                      //   child: club.getClubNameClickable(context,
                      //       isRightClub: true),
                      // ),
                    ],
                  ),
                ),
                drawer: const AppDrawer(),
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
                                icon: Icons.play_circle,
                                text: 'Played (${gamesPlayed.length})'),

                            /// Current games title
                            if (gamesCurrent.length > 0)
                              buildTabWithIcon(
                                  icon: Icons.notifications_active,
                                  text: 'Current (${gamesCurrent.length})'),

                            /// Incoming games title
                            buildTabWithIcon(
                                icon: Icons.arrow_circle_right_outlined,
                                text: 'Incoming (${gamesIncoming.length})'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              DefaultTabController(
                                length: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Played Games level 2 tabs
                                    TabBar(
                                      tabs: [
                                        // Current season played games
                                        buildTabWithIcon(
                                            icon: Icons.play_circle,
                                            text:
                                                'Current season (${gamesPlayed.length})'),
                                        buildTabWithIcon(
                                            icon: Icons
                                                .keyboard_double_arrow_left,
                                            text: 'Previous seasons'),
                                      ],
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          _buildGameList(gamesPlayed),
                                          _buildHistoricGames(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// Current games (if exists)
                              if (gamesCurrent.length > 0)
                                _buildGameList(gamesCurrent),

                              /// Incoming games
                              DefaultTabController(
                                length: 2, // Number of tabs
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TabBar(
                                      tabs: [
                                        // Current season played games
                                        buildTabWithIcon(
                                            icon: Icons.play_circle,
                                            text:
                                                'Current season (${gamesIncoming.length + club.teamComps.length})'),
                                        // Next season games
                                        buildTabWithIcon(
                                            icon: Icons
                                                .keyboard_double_arrow_right,
                                            text: 'Next season (14)'),
                                      ],
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          DefaultTabController(
                                            length: 2, // Number of tabs
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TabBar(
                                                  tabs: [
                                                    // Current season organized games
                                                    buildTabWithIcon(
                                                        icon: Icons
                                                            .calendar_month,
                                                        text:
                                                            'Planned (${gamesIncoming.length})'),

                                                    // Current season unorganized games yet
                                                    buildTabWithIcon(
                                                        icon:
                                                            Icons.edit_calendar,
                                                        text:
                                                            'Unplanned (${club.teamComps.length})'),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: TabBarView(
                                                    children: [
                                                      _buildGameList(
                                                          gamesIncoming),
                                                      _buildTeamCompList(club),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildFutureGames(),
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
                // child: _buildGameDescription(game),
                child:
                    // game.getGamePresentation(context, idClubSelected: widget.idClub),
                    game.getGamePresentation(context),
              );
            },
            // leading: Text('test')
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFutureGames() {
    /// Get the club
    Stream<Club> _clubStream = supabase
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idClub)
        .map((maps) => Club.fromMap(maps.first))

        /// Fetch the games where the club is left
        .switchMap((Club club) {
          return supabase
              .from('games')
              .stream(primaryKey: ['id'])
              .eq('id_club_left', club.id)
              .map((maps) =>
                  maps.map((map) => Game.fromMap(map, widget.idClub)).toList())
              .map((games) {
                games
                    .where((game) => game.seasonNumber > club.seasonNumber)
                    .forEach((game) {
                  club.games.add(game);
                });
                return club;
              });
        })

        /// Fetch the games where the club is right
        .switchMap((Club club) {
          return supabase
              .from('games')
              .stream(primaryKey: ['id'])
              .eq('id_club_right', club.id)
              .map((maps) =>
                  maps.map((map) => Game.fromMap(map, widget.idClub)).toList())
              .map((games) {
                games
                    .where((game) => game.seasonNumber > club.seasonNumber)
                    .forEach((game) {
                  club.games.add(game);
                });
                // Order club.games by dateStart
                club.games.sort((a, b) => a.dateStart.compareTo(b.dateStart));
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
                for (TeamComp teamcomp in teamComps.where(
                    (teamcomp) => teamcomp.seasonNumber > club.seasonNumber)) {
                  // If no game exists for the week of the teamcomp
                  if (!club.games
                      .any((game) => game.weekNumber == teamcomp.weekNumber)) {
                    club.teamComps.add(teamcomp);
                  }
                }
                return club;
              });
        });

    return StreamBuilder<Club>(
        stream: _clubStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('No data found'),
            );
          } else {
            Club club = snapshot.data!;
            return DefaultTabController(
              length: 2, // Number of tabs
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons
                                .calendar_month), // Add the desired icon here
                            SizedBox(
                                width:
                                    5), // Add some spacing between the icon and text
                            Text(
                                // 'Current season ${club.seasonNumber}: (${gamesPlayed.length})'),
                                'Organized games (${club.games.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons
                                .edit_calendar), // Add the desired icon here
                            SizedBox(
                                width:
                                    5), // Add some spacing between the icon and text
                            Text(
                                // 'Current season ${club.seasonNumber}: (${gamesPlayed.length})'),
                                'Not yet organized games (${club.teamComps.length})'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildGameList(club.games),
                        _buildTeamCompList(club),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget _buildHistoricGames() {
    /// Get the club
    Stream<Club> _clubStream = supabase
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idClub)
        .map((maps) => Club.fromMap(maps.first))

        /// Fetch the games where the club is left
        .switchMap((Club club) {
          return supabase
              .from('games')
              .stream(primaryKey: ['id'])
              .eq('id_club_left', club.id)
              .map((maps) =>
                  maps.map((map) => Game.fromMap(map, widget.idClub)).toList())
              .map((games) {
                games
                    .where((game) => game.seasonNumber < club.seasonNumber)
                    .forEach((game) {
                  club.games.add(game);
                });
                return club;
              });
        })

        /// Fetch the games where the club is right
        .switchMap((Club club) {
          return supabase
              .from('games')
              .stream(primaryKey: ['id'])
              .eq('id_club_right', club.id)
              .map((maps) =>
                  maps.map((map) => Game.fromMap(map, widget.idClub)).toList())
              .map((games) {
                games
                    .where((game) => game.seasonNumber < club.seasonNumber)
                    .forEach((game) {
                  club.games.add(game);
                });
                // Order club.games by dateStart
                club.games.sort((a, b) => a.dateStart.compareTo(b.dateStart));
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
        });

    return StreamBuilder<Club>(
        stream: _clubStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('No club found for fetching historic games'),
            );
          } else {
            // List<Game> games = snapshot.data!.games;
            Club club = snapshot.data!;
            if (club.games.isEmpty) {
              return const Center(
                child: Text('No historic games found'),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: club.games.length,
                    itemBuilder: (context, index) {
                      final Game game = club.games[index];
                      return InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(GamePage.route(game.id, widget.idClub));
                          },
                          // child: _buildGameDescription(game),
                          child: game.getGamePresentation(context));
                    },
                    // leading: Text('test')
                  ),
                ),
              ],
            );
          }
        });
  }
}
