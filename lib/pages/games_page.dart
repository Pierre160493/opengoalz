import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/teamComp.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/pages/teamCompPage.dart';
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
              .map((maps) => maps
                  .map((map) => Club.fromMap(
                      map: map, myUserId: supabase.auth.currentUser!.id))
                  .toList())
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
                return club;
              });
        });

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
                        /// Level 1 Tabs
                        TabBar(
                          tabs: [
                            /// Played games title
                            buildTab(Icons.arrow_circle_left_outlined,
                                'Played (${gamesPlayed.length})'),

                            /// Current games title
                            if (gamesCurrent.length > 0)
                              buildTab(Icons.play_circle,
                                  'Current (${gamesCurrent.length})'),

                            /// Incoming games title
                            buildTab(Icons.arrow_circle_right_outlined,
                                'Incoming (${gamesIncoming.length})'),
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
                                        buildTab(Icons.play_circle,
                                            'Current season (${gamesPlayed.length})'),
                                        buildTab(
                                            Icons.keyboard_double_arrow_left,
                                            'Previous seasons'),
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
                                        buildTab(Icons.play_circle,
                                            'Current season (${gamesIncoming.length + club.teamComps.length})'),
                                        // Next season games
                                        buildTab(
                                            Icons.keyboard_double_arrow_right,
                                            'Next season (14)'),
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
                                                    buildTab(
                                                        Icons.calendar_month,
                                                        'Organized games (${gamesIncoming.length})'),

                                                    // Current season unorganized games yet
                                                    buildTab(
                                                        Icons.edit_calendar,
                                                        'Not yet organized games (${club.teamComps.length})'),
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

  Widget buildTab(IconData icon, String text) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(width: 6), // Add some spacing between the icon and text
          Text(text),
        ],
      ),
    );
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
              .map((maps) => maps.map((map) => Game.fromMap(map)).toList())
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
              .map((maps) => maps
                  .map((map) => Club.fromMap(
                      map: map, myUserId: supabase.auth.currentUser!.id))
                  .toList())
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
              .map((maps) => maps.map((map) => Game.fromMap(map)).toList())
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
              .map((maps) => maps
                  .map((map) => Club.fromMap(
                      map: map, myUserId: supabase.auth.currentUser!.id))
                  .toList())
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
