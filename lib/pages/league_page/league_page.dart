import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/functions/stringFunctions.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/events/event.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/pages/league_page/league_page_games_tab.dart';
import 'package:opengoalz/pages/league_page/league_page_main_tab.dart';
import 'package:opengoalz/pages/league_page/league_page_stats_tab.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import '../../constants.dart';

class LeaguePage extends StatefulWidget {
  final int idLeague;
  final int? idSelectedClub;
  final int? seasonNumber;
  final bool isReturningBotClub;

  const LeaguePage({
    Key? key,
    required this.idLeague,
    this.idSelectedClub,
    this.seasonNumber,
    this.isReturningBotClub = false,
  }) : super(key: key);

  static Route<Club?> route(int idLeague,
      {int? idClub, bool isReturningBotClub = false}) {
    return MaterialPageRoute<Club?>(
      builder: (context) => LeaguePage(
        idLeague: idLeague,
        idSelectedClub: idClub,
        isReturningBotClub: isReturningBotClub,
      ),
    );
  }

  @override
  State<LeaguePage> createState() => _RankingPageState();
}

class _RankingPageState extends State<LeaguePage> {
  late Stream<League> _leagueStream;
  int? _selectedSeason;
  List<int> _gamesId = [];

  @override
  void initState() {
    super.initState();
    _selectedSeason = widget.seasonNumber;
    _fetchSeasonNumberAndGamesIds();
  }

  Future<void> _fetchSeasonNumberAndGamesIds() async {
    if (_selectedSeason == null) {
      _selectedSeason = await supabase
          .from('leagues')
          .select('season_number')
          .eq('id', widget.idLeague)
          .then((value) => value.first['season_number'] as int);
    }

    _gamesId = await supabase
        .from('games')
        .select('id')
        .eq('id_league', widget.idLeague)
        .eq('season_number', _selectedSeason!)
        .then((value) => value.map((e) => e['id'] as int).toList());
    print('_gamesId: $_gamesId');
    _fetchLeagueData();
  }

  Future<void> _fetchLeagueData() async {
    _leagueStream = supabase
        .from('leagues')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idLeague)
        .map((maps) {
          if (maps.isEmpty) {
            throw StateError('No league found with id ${widget.idLeague}');
          }
          print('maps: $maps');
          return maps
              .map((map) =>
                  League.fromMap(map, idSelectedClub: widget.idSelectedClub))
              .first;
        })
        .switchMap((League league) {
          return supabase
              .from('games')
              .stream(primaryKey: ['id'])
              .inFilter('id', _gamesId)
              .order('date_start', ascending: true)
              .map((maps) => maps
                  .map((map) => Game.fromMap(map, widget.idSelectedClub))
                  .toList())
              .map((List<Game> games) {
                league.games = games;
                return league;
              });
        })
        .switchMap((League league) {
          List<int> clubsIds = league.games
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
              .map((clubs) {
                league.clubsAll = clubs;
                league.clubsLeague = clubs
                    .where((Club club) => league.games
                        .where((game) => game.weekNumber == 1)
                        .expand((game) => [game.idClubLeft, game.idClubRight])
                        .contains(club.id))
                    .toList();
                for (Game game in league.games) {
                  if (game.idClubLeft != null) {
                    game.leftClub = league.clubsAll.firstWhere(
                      (club) => club.id == game.idClubLeft,
                      orElse: () => throw Exception(
                          'DATABASE ERROR: Club not found for the left club with id: ${game.idClubLeft} for the game with id: ${game.id}'),
                    );
                  }
                  if (game.idClubRight != null) {
                    game.rightClub = league.clubsAll.firstWhere(
                        (club) => club.id == game.idClubRight,
                        orElse: () => throw Exception(
                            'DATABASE ERROR: Club not found for the right club with id: ${game.idClubRight} for the game with id: ${game.id}'));
                  }
                }
                return league;
              });
        })
        .switchMap((League league) {
          return supabase
              .from('games_description')
              .stream(primaryKey: ['id'])
              .inFilter(
                  'id',
                  league.games
                      .map((game) => game.idDescription)
                      .map((id) => id)
                      .toSet()
                      .toList())
              .map((maps) => maps)
              .map((map) {
                for (Game game in league.games) {
                  game.description = map.firstWhere(
                          (map) => map['id'] == game.idDescription,
                          orElse: () => throw StateError(
                              'No description found for game with id ${game.idDescription}'))[
                      'description'];
                }
                return league;
              });
        })
        .switchMap((League league) {
          return supabase
              .from('game_events')
              .stream(primaryKey: ['id'])
              .inFilter('id_game', league.games.map((game) => game.id).toList())
              .map((maps) => maps.map((map) => GameEvent.fromMap(map)).toList())
              .map((List<GameEvent> events) {
                for (Game game in league.games) {
                  game.events = events
                      .where((GameEvent event) => event.idGame == game.id)
                      .toList();
                }
                return league;
              });
        })
        .switchMap((League league) async* {
          await _updateClubStatistics(league);
          yield league;
        });
  }

  Future<void> _updateClubStatistics(League league) async {
    for (Game game
        in league.games.where((Game game) => game.weekNumber <= 10)) {
      if (game.isPlaying == false) {
        print(
            'Club IDs: ${league.clubsLeague.map((club) => club.id).toList()}');
        print(
            'game: ${game.id}: ${game.idClubLeft} vs ${game.idClubRight} [${game.scoreLeft} - ${game.scoreRight}]');
        Club leftClub = league.clubsLeague.firstWhere(
          (Club club) => club.id == game.idClubLeft,
          orElse: () => throw Exception(
              'DATABASE ERROR: Club not found for the left club with id: ${game.idClubLeft} for the game with id: ${game.id}'),
        );
        Club rightClub = league.clubsLeague.firstWhere(
          (Club club) => club.id == game.idClubRight,
          orElse: () => throw Exception(
              'DATABASE ERROR: Club not found for the right club with id: ${game.idClubRight} for the game with id: ${game.id}'),
        );

        leftClub.goalsScored += game.scoreLeft!;
        rightClub.goalsTaken += game.scoreLeft!;
        leftClub.goalsTaken += game.scoreRight!;
        rightClub.goalsScored += game.scoreRight!;

        if (game.scoreLeft! > game.scoreRight!) {
          leftClub.points += 3;
          leftClub.victories += 1;
          rightClub.defeats += 1;
        } else if (game.scoreLeft! < game.scoreRight!) {
          leftClub.defeats += 1;
          rightClub.victories += 1;
          rightClub.points += 3;
        } else {
          leftClub.draws += 1;
          leftClub.points += 1;
          rightClub.draws += 1;
          rightClub.points += 1;
        }
      }
    }

    league.clubsLeague.sort((a, b) {
      int compare = b.points.compareTo(a.points);
      if (compare != 0) {
        return compare;
      } else {
        return (b.goalsScored - b.goalsTaken)
            .compareTo(a.goalsScored - a.goalsTaken);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchSeasonNumberAndGamesIds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingCircularAndText('Loading League...');
        } else if (snapshot.hasError) {
          return Center(
            child: Text('ERROR: ${snapshot.error}'),
          );
        } else {
          return StreamBuilder<League>(
            stream: _leagueStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingCircularAndText('Loading League...');
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('ERROR: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                League league = snapshot.data!;
                return Scaffold(
                  appBar: AppBar(
                    title: Tooltip(
                        message:
                            '${positionWithIndex(league.number)} league of ${positionWithIndex(league.level)} division of ${league.continent}',
                        child: Text('League ${league.name.toString()}')),
                    leading: goBackIconButton(context),
                  ),
                  // drawer: const AppDrawer(),
                  body: MaxWidthContainer(
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          ListTile(
                            leading: IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                setState(() {
                                  if (_selectedSeason != null) {
                                    _selectedSeason = (_selectedSeason! - 1)
                                        .clamp(1, _selectedSeason!);
                                    _fetchLeagueData();
                                  }
                                });
                              },
                            ),
                            title: Text('Season ${_selectedSeason ?? 'N/A'}'),
                            trailing: IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                setState(() {
                                  if (_selectedSeason != null) {
                                    _selectedSeason = _selectedSeason! + 1;
                                    _fetchLeagueData();
                                  }
                                });
                              },
                            ),
                          ),
                          TabBar(
                            tabs: [
                              buildTabWithIcon(
                                  icon: Icons.format_list_numbered,
                                  text: 'Rankings'),
                              buildTabWithIcon(
                                  icon: Icons.event, text: 'Games'),
                              buildTabWithIcon(icon: iconStats, text: 'Stats'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                /// League main tab
                                LeaguePageMainTab(
                                    league: league,
                                    isReturningBotClub:
                                        widget.isReturningBotClub),

                                /// Games tab
                                LeaguePageGamesTab(league: league),

                                /// Stats tab
                                LeaguePageStatsTab(league: league),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
