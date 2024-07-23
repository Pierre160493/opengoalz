import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/events/event.dart';
import 'package:opengoalz/classes/teamComp.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/classes/game/class/game.dart';
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
    /// Get the club
    _clubStream = supabase
            .from('clubs')
            .stream(primaryKey: ['id'])
            .eq('id', widget.idClub)
            .map((maps) => Club.fromMap(
                map: maps.first, myUserId: supabase.auth.currentUser!.id))

            /// Fetch the games where the club is left
            .switchMap((Club club) {
              return supabase
                  .from('games')
                  .stream(primaryKey: ['id'])
                  .eq('id_club_left', club.id)
                  .map((maps) => maps.map((map) => Game.fromMap(map)).toList())
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
                  .map((maps) => maps.map((map) => Game.fromMap(map)).toList())
                  .map((games) {
                    games
                        .where((game) => game.seasonNumber == club.seasonNumber)
                        .forEach((game) {
                      club.games.add(game);
                    });
                    // Order club.games by dateStart
                    club.games
                        .sort((a, b) => a.dateStart.compareTo(b.dateStart));
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
                  .map((maps) => maps
                      .map((map) => Club.fromMap(
                          map: map, myUserId: supabase.auth.currentUser!.id))
                      .toList())
                  .map((clubs) {
                    for (var game in club.games) {
                      game.rightClub = clubs
                          .firstWhere((club) => club.id == game.idClubRight);
                      game.leftClub = clubs
                          .firstWhere((club) => club.id == game.idClubLeft);
                    }
                    return club;
                  });
            })
            .switchMap((Club club) {
              return supabase
                  .from('games_teamcomp')
                  .stream(primaryKey: ['id'])
                  .eq('id_club', club.id)
                  .map((maps) =>
                      maps.map((map) => TeamComp.fromMap(map)).toList())
                  .map((List<TeamComp> teamcomps) {
                    for (TeamComp teamcomp in teamcomps.where((teamcomp) =>
                        teamcomp.seasonNumber == club.seasonNumber)) {
                      // If no game exists for the week of the teamcomp
                      if (!club.games.any(
                          (game) => game.weekNumber == teamcomp.weekNumber)) {
                        club.teamcomps.add(teamcomp);
                      }
                    }
                    return club;
                  });
            })

        /// Fetch the game events for the games
        // .switchMap((Club club) {
        //   return supabase
        //       .from('game_events')
        //       .stream(primaryKey: ['id'])
        //       .inFilter('id_game', club.games.map((game) => game.id).toList())
        //       .map((maps) => maps.map((map) => GameEvent.fromMap(map)).toList())
        //       .map((events) {
        //         for (var game in club.games) {
        //           game.events =
        //               events.where((event) => event.idGame == game.id).toList();
        //         }
        //         return club;
        //       });
        // })
        ;

    super.initState();
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

              DateTime now = DateTime.now();

              /// Loop through games to store them in the right list
              for (Game game in club.games) {
                /// Games for this season
                /// Current games
                if (game.dateStart.isAfter(now) &&
                    game.dateStart
                        .isBefore(now.add(const Duration(hours: 3)))) {
                  gamesCurrent.add(game);

                  /// Played games for this season
                } else if (game.isPlayed) {
                  gamesPlayed.add(game);

                  /// Incoming games for this season
                } else {
                  gamesIncoming.add(game);
                }
              }
              return Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      Text('Games Page for ${club.nameClub}'),
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
                        TabBar(
                          tabs: [
                            /// Played games title
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons
                                      .arrow_circle_left_outlined), // Add the desired icon here
                                  SizedBox(
                                      width:
                                          5), // Add some spacing between the icon and text
                                  Text('Played (${gamesPlayed.length})'),
                                ],
                              ),
                            ),

                            /// Current games title
                            if (gamesCurrent.length > 0)
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons
                                        .play_circle), // Add the desired icon here
                                    SizedBox(
                                        width:
                                            5), // Add some spacing between the icon and text
                                    Text('Current (${gamesCurrent.length})'),
                                  ],
                                ),
                              ),

                            /// Incoming games title
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons
                                      .arrow_circle_right_outlined), // Add the desired icon here
                                  SizedBox(
                                      width:
                                          5), // Add some spacing between the icon and text
                                  Text('Incoming (${gamesIncoming.length})'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              /// Played games
                              DefaultTabController(
                                length: 2, // Number of tabs
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TabBar(
                                      tabs: [
                                        Tab(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons
                                                  .arrow_back_outlined), // Add the desired icon here
                                              SizedBox(
                                                  width:
                                                      5), // Add some spacing between the icon and text
                                              Text(
                                                  // 'Current season ${club.seasonNumber}: (${gamesPlayed.length})'),
                                                  'Current season (${gamesPlayed.length})'),
                                            ],
                                          ),
                                        ),
                                        Tab(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons
                                                  .keyboard_double_arrow_left), // Add the desired icon here
                                              SizedBox(
                                                  width:
                                                      5), // Add some spacing between the icon and text
                                              Text(
                                                  // 'Current season ${club.seasonNumber}: (${gamesPlayed.length})'),
                                                  'Previous seasons'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          _buildGameList(gamesPlayed),
                                          _buildHistoricGames(widget.idClub),
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
                                        Tab(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons
                                                  .arrow_forward_outlined), // Add the desired icon here
                                              SizedBox(
                                                  width:
                                                      5), // Add some spacing between the icon and text
                                              Text(
                                                  'Current season (${gamesIncoming.length})'),
                                            ],
                                          ),
                                        ),
                                        Tab(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons
                                                  .keyboard_double_arrow_right), // Add the desired icon here
                                              SizedBox(
                                                  width:
                                                      5), // Add some spacing between the icon and text
                                              Text('Next season'),
                                            ],
                                          ),
                                        ),
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
                                                    Tab(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons
                                                              .calendar_month), // Add the desired icon here
                                                          SizedBox(
                                                              width:
                                                                  5), // Add some spacing between the icon and text
                                                          Text(
                                                              // 'Current season ${club.seasonNumber}: (${gamesPlayed.length})'),
                                                              'Organized games (${gamesIncoming.length})'),
                                                        ],
                                                      ),
                                                    ),
                                                    Tab(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons
                                                              .edit_calendar), // Add the desired icon here
                                                          SizedBox(
                                                              width:
                                                                  5), // Add some spacing between the icon and text
                                                          Text(
                                                              'Not yet organized games (${club.teamcomps.length})'),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: TabBarView(
                                                    children: [
                                                      _buildGameList(
                                                          gamesIncoming),
                                                      _buildTeamCompList(
                                                          club.teamcomps),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildFutureGames(widget.idClub),
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
                  Navigator.of(context).push(GamePage.route(game.id));
                },
                // child: _buildGameDescription(game),
                child: game.getGameDetails(context),
              );
            },
            // leading: Text('test')
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCompList(List<TeamComp> teamComps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: teamComps.length,
            itemBuilder: (context, index) {
              final TeamComp teamComp = teamComps[index];
              return InkWell(
                // onTap: () {
                //   Navigator.of(context).push(GamePage.route(game.id));
                // },
                // child: _buildGameDescription(game),
                child: ListTile(
                  leading: Icon(Icons.sports_soccer_outlined),
                  title: Text('Week ${teamComp.weekNumber}'),
                  subtitle: Text('Team composition'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              );
            },
            // leading: Text('test')
          ),
        ),
      ],
    );
  }

  Widget _buildFutureGames(int idClub) {
    Stream<Club> _clubStream =

        /// Get the club
        supabase
            .from('clubs')
            .stream(primaryKey: ['id'])
            .eq('id', widget.idClub)
            .map((maps) => Club.fromMap(
                map: maps.first, myUserId: supabase.auth.currentUser!.id))

            /// Get the games of the club for the previous seasons when club was left
            .switchMap((Club club) {
              return supabase
                  .from('games')
                  .stream(primaryKey: ['id'])
                  .eq('id_club_left', club.id)
                  .map((maps) => maps.map((map) => Game.fromMap(map)).toList())
                  .map((List<Game> games) {
                    print('testPG_left n: ${games.length}');
                    for (Game game in games.where(
                        (game) => game.seasonNumber > club.seasonNumber)) {
                      print('testPG_left: ${game.id} @ ${game.dateStart}');
                      club.games.add(game);
                    }
                    return club;
                  });
            })

            /// Get the games of the club for the previous seasons when club was left
            .switchMap((Club club) {
              return supabase
                  .from('games')
                  .stream(primaryKey: ['id'])
                  .eq('id_club_right', club.id)
                  .map((maps) => maps.map((map) => Game.fromMap(map)).toList())
                  .map((List<Game> games) {
                    print('testPG_right n: ${games.length}');
                    for (Game game in games.where(
                        (game) => game.seasonNumber > club.seasonNumber)) {
                      print('testPG_right: ${game.id} @ ${game.dateStart}');
                      club.games.add(game);
                    }
                    return club;
                  });
            })

        /// Fetch the teamcomps for the club
        // .switchMap((Club club) {
        //   return supabase
        //       .from('games_teamcomp')
        //       .stream(primaryKey: ['id'])
        //       .eq('id_club', club.id)
        //       .map((maps) =>
        //           maps.map((map) => TeamComp.fromMap(map)).toList())
        //       .map((List<TeamComp> teamComps) {
        //         /// Add the teamcomps to the club but only for this season
        //         for (TeamComp teamComp in teamComps.where((teamComp) =>
        //             teamComp.seasonNumber > club.seasonNumber)) {
        //           // If the game isn't organized yet
        //           var gameIds = club.games
        //               .expand((game) =>
        //                   [game.idTeamcompLeft, game.idTeamcompRight])
        //               .toList();
        //           if (!gameIds.contains(teamComp.id)) {
        //             club.teamcomps.add(teamComp);
        //           }
        //         }
        //         return club;
        //       });
        // })
        ;

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
                                'Not yet organized games (${club.teamcomps.length})'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildGameList(club.games),
                        Text(
                            'Not yet organized Games (${club.teamcomps.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget _buildHistoricGames(int idClub) {
    Stream<Club> _clubStream =

        /// Get the club
        supabase
            .from('clubs')
            .stream(primaryKey: ['id'])
            .eq('id', widget.idClub)
            .map((maps) => Club.fromMap(
                map: maps.first, myUserId: supabase.auth.currentUser!.id))

            /// Get the games of the club for the previous seasons when club was left
            .switchMap((Club club) {
              return supabase
                  .from('games')
                  .stream(primaryKey: ['id'])
                  .eq('id_club_left', club.id)
                  .map((maps) => maps.map((map) => Game.fromMap(map)).toList())
                  .map((List<Game> games) {
                    for (Game game in games.where(
                        (game) => game.seasonNumber < club.seasonNumber)) {
                      club.games.add(game);
                    }
                    return club;
                  });
            })

            /// Get the games of the club for the previous seasons when club was left
            .switchMap((Club club) {
              return supabase
                  .from('games')
                  .stream(primaryKey: ['id'])
                  .eq('id_club_right', club.id)
                  .map((maps) => maps.map((map) => Game.fromMap(map)).toList())
                  .map((List<Game> games) {
                    for (Game game in games.where(
                        (game) => game.seasonNumber < club.seasonNumber)) {
                      club.games.add(game);
                    }
                    return club;
                  });
            })

            /// Get the clubs for the games
            .switchMap((Club club) {
              List<int> clubIdsLeft = club.games
                  .where((game) => game.idClubLeft != null)
                  .map((game) => game.idClubLeft!)
                  .toSet()
                  .toList();

              List<int> clubIdsRight = club.games
                  .where((game) => game.idClubRight != null)
                  .map((game) => game.idClubRight!)
                  .toSet()
                  .toList();

              return supabase
                  .from('clubs')
                  .stream(primaryKey: ['id'])
                  .inFilter('id', [
                    ...clubIdsLeft,
                    ...clubIdsRight,
                  ])
                  .map((maps) => maps
                      .map((map) => Club.fromMap(
                          map: map, myUserId: supabase.auth.currentUser!.id))
                      .toList())
                  .map((clubs) {
                    for (var game in club.games) {
                      game.leftClub = clubs.firstWhere(
                          (club) => club.id == game.idClubLeft,
                          orElse: () => throw Exception(
                              'DATABASE ERROR: Club not found for the left club with id: ${game.idClubLeft} for the game with id: ${game.id}'));
                      ;
                      game.rightClub = clubs.firstWhere(
                          (club) => club.id == game.idClubRight,
                          orElse: () => throw Exception(
                              'DATABASE ERROR: Club not found for the right club with id: ${game.idClubRight} for the game with id: ${game.id}'));
                      ;
                    }
                    return club;
                  })
                  .switchMap((Club club) {
                    return supabase
                        .from('game_events')
                        .stream(primaryKey: ['id'])
                        .inFilter('id_game',
                            club.games.map((game) => game.id).toList())
                        .map((maps) =>
                            maps.map((map) => GameEvent.fromMap(map)).toList())
                        .map((events) {
                          for (Game game in club.games) {
                            game.events = events
                                .where((event) => event.idGame == game.id)
                                .toList();
                          }
                          return club;
                        });
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
                          Navigator.of(context).push(GamePage.route(game.id));
                        },
                        // child: _buildGameDescription(game),
                        child: game.getGameDetails(context),
                      );
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
