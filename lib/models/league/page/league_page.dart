import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/functions/stringFunctions.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/events/event.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/models/league/page/games_tab/league_page_games_tab.dart';
import 'package:opengoalz/models/league/page/main_tab/league_page_main_tab.dart';
import 'package:opengoalz/models/league/page/league_page_open_related_leagues.dart';
import 'package:opengoalz/models/league/page/stats_tab/league_page_stats_tab.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import '../../../constants.dart';

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
  late int _selectedSeason;
  List<int> _gamesId = [];

  @override
  void initState() {
    super.initState();
    _fetchSeasonNumberAndGamesIds();
  }

  Future<void> _fetchSeasonNumberAndGamesIds() async {
    if (widget.seasonNumber == null) {
      _selectedSeason = await supabase
          .from('leagues')
          .select('season_number')
          .eq('id', widget.idLeague)
          .then((value) => value.first['season_number'] as int);
    } else {
      _selectedSeason = widget.seasonNumber!;
    }

    _gamesId = await supabase
        .from('games')
        .select('id')
        .eq('id_league', widget.idLeague)
        .eq('season_number', _selectedSeason)
        .then((value) => value.map((e) => e['id'] as int).toList());
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
              return maps
                  .map((map) => League.fromMap(map,
                      idSelectedClub: widget.idSelectedClub,
                      selectedSeasonNumber: _selectedSeason))
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
                  .map((maps) => maps
                      .map((map) => Club.fromMap(
                          map,
                          Provider.of<UserSessionProvider>(context,
                                  listen: false)
                              .user))
                      .toList())
                  .map((List<Club> clubs) {
                    clubs.sort((a, b) =>
                        a.clubData.posLeague.compareTo(b.clubData.posLeague));
                    league.clubsAll = clubs;
                    league.clubsLeague = clubs
                        .where((Club club) => league.games
                            .where((game) => game.weekNumber == 1)
                            .expand(
                                (game) => [game.idClubLeft, game.idClubRight])
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
                  .inFilter(
                      'id_game', league.games.map((game) => game.id).toList())
                  .map((maps) =>
                      maps.map((map) => GameEvent.fromMap(map)).toList())
                  .map((List<GameEvent> events) {
                    for (Game game in league.games) {
                      game.events = events
                          .where((GameEvent event) => event.idGame == game.id)
                          .toList();
                    }
                    return league;
                  });
            })
        // .switchMap((League league) async* {
        //   await _updateClubStatistics(league);
        //   yield league;
        // })
        ;
  }

  // Future<void> _updateClubStatistics(League league) async {
  //   /// Clear previous statistics

  //   league.clubsLeague.forEach((club) {
  //     club.goalsScored = 0;
  //     club.goalsTaken = 0;
  //     club.points = 0;
  //     club.victories = 0;
  //     club.draws = 0;
  //     club.defeats = 0;
  //     club.lisPoints = [0];
  //   });

  //   /// Loop through each week of the league
  //   for (int i = 1; i <= 10; i++) {
  //     league.clubsLeague.forEach((club) {
  //       club.lisPoints.add(-1);
  //     });

  //     /// Loop through each game of the week
  //     for (Game game
  //         in league.games.where((Game game) => game.weekNumber == i)) {
  //       if (game.isPlaying == false) {
  //         print(
  //             'Club IDs: ${league.clubsLeague.map((club) => club.id).toList()}');
  //         print(
  //             'game: ${game.id}: ${game.idClubLeft} vs ${game.idClubRight} [${game.scoreLeft} - ${game.scoreRight}]');
  //         Club leftClub = league.clubsLeague.firstWhere(
  //           (Club club) => club.id == game.idClubLeft,
  //           orElse: () => throw Exception(
  //               'DATABASE ERROR: Club not found for the left club with id: ${game.idClubLeft} for the game with id: ${game.id}'),
  //         );
  //         Club rightClub = league.clubsLeague.firstWhere(
  //           (Club club) => club.id == game.idClubRight,
  //           orElse: () => throw Exception(
  //               'DATABASE ERROR: Club not found for the right club with id: ${game.idClubRight} for the game with id: ${game.id}'),
  //         );

  //         leftClub.goalsScored += game.scoreLeft!;
  //         rightClub.goalsTaken += game.scoreLeft!;
  //         leftClub.goalsTaken += game.scoreRight!;
  //         rightClub.goalsScored += game.scoreRight!;

  //         if (game.scoreLeft! > game.scoreRight!) {
  //           leftClub.points += 3;
  //           leftClub.victories += 1;
  //           rightClub.defeats += 1;
  //         } else if (game.scoreLeft! < game.scoreRight!) {
  //           leftClub.defeats += 1;
  //           rightClub.victories += 1;
  //           rightClub.points += 3;
  //         } else {
  //           leftClub.draws += 1;
  //           leftClub.points += 1;
  //           rightClub.draws += 1;
  //           rightClub.points += 1;
  //         }
  //       }
  //     }
  //   }
  //   league.clubsLeague.sort((a, b) {
  //     int compare = b.points.compareTo(a.points);
  //     if (compare != 0) {
  //       return compare;
  //     } else {
  //       return (b.goalsScored - b.goalsTaken)
  //           .compareTo(a.goalsScored - a.goalsTaken);
  //     }
  //   });
  // }

  Future<void> _showSeasonInputDialog(League league) async {
    final TextEditingController seasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to manage the state of the dialog's content
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            // Calculate validity inside the builder so it re-evaluates on setStateDialog
            final int? parsedSeason = int.tryParse(seasonController.text);
            final bool isSeasonInputValid = parsedSeason != null &&
                parsedSeason > 0 &&
                parsedSeason != league.selectedSeasonNumber;

            return persoAlertDialogWithConstrainedContent(
              title: const Text('Modify Selected Season',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                children: [
                  ListTile(
                      leading: Icon(Icons.info,
                          color: Colors.green, size: iconSizeMedium),
                      title: Text(
                        league.selectedSeasonNumber.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Currently selected season',
                        style: styleItalicBlueGrey,
                      ),
                      shape: shapePersoRoundedBorder(Colors.green)),
                  TextField(
                    controller: seasonController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Select a season number',
                    ),
                    onChanged: (value) {
                      // Trigger a rebuild of the dialog's state when text changes
                      setStateDialog(() {});
                    },
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: persoCancelRow(),
                    ),
                    TextButton(
                      onPressed: isSeasonInputValid
                          ? () {
                              // parsedSeason is already calculated and validated
                              setState(() {
                                // This is the main page's setState
                                _selectedSeason = parsedSeason;
                                _fetchLeagueData();
                              });
                              Navigator.of(context).pop(); // Close the dialog
                            }
                          : null, // Button is disabled if input is not valid
                      child: persoValidRow(
                        isSeasonInputValid
                            ? 'Open Season ${parsedSeason}'
                            : 'Invalid Season',
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
    // Dispose the controller after the dialog is closed
    seasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchSeasonNumberAndGamesIds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingCircularAndText('Loading League...');
        } else if (snapshot.hasError) {
          return ErrorWithBackButton(
            errorMessage: 'Error loading league data: ${snapshot.error}',
          );
        } else {
          return StreamBuilder<League>(
            stream: _leagueStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingCircularAndText('Loading League...');
              } else if (snapshot.hasError) {
                return ErrorWithBackButton(
                  errorMessage: 'Error loading league: ${snapshot.error}',
                );
              } else if (!snapshot.hasData) {
                return ErrorWithBackButton(
                  errorMessage: 'No league data available',
                );
              } else {
                League league = snapshot.data!;
                return Scaffold(
                  appBar: AppBar(
                    title: Row(
                      children: [
                        Tooltip(
                            message:
                                '${positionWithIndex(league.number)} league of ${positionWithIndex(league.level)} division of ${league.continent}',
                            child: Text('League ${league.name.toString()}')),
                      ],
                    ),
                    leading: goBackIconButton(context),
                    actions: [
                      /// Refresh button to reload the league data
                      IconButton(
                        tooltip: 'Refresh Page',
                        icon: Icon(Icons.refresh,
                            size: iconSizeMedium, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _fetchLeagueData();
                          });
                        },
                      ),

                      /// Change season button
                      IconButton(
                        tooltip: 'Previous Season',
                        icon: Icon(Icons.arrow_back,
                            size: iconSizeMedium, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _selectedSeason =
                                (_selectedSeason - 1).clamp(1, _selectedSeason);
                            _fetchLeagueData();
                          });
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          _showSeasonInputDialog(league);
                        },
                        child: Tooltip(
                          message: 'Season Number',
                          waitDuration: Duration(milliseconds: 500),
                          child: Text('S${league.selectedSeasonNumber}',
                              style: TextStyle(
                                  fontSize: iconSizeSmall,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),

                      IconButton(
                        tooltip: 'Next Season',
                        icon: Icon(Icons.arrow_forward,
                            size: iconSizeMedium, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _selectedSeason = _selectedSeason + 1;
                            _fetchLeagueData();
                          });
                        },
                      ),

                      /// Open other related leagues
                      IconButton(
                        tooltip: 'Open related leagues',
                        icon: Icon(Icons.dataset_linked,
                            size: iconSizeMedium, color: Colors.green),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return persoAlertDialogWithConstrainedContent(
                                title: Text(
                                  'Related Leagues',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                content: LeagueOtherLeaguesSelectionWidget(
                                    league: league),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.close,
                                                color: Colors.red,
                                                size: iconSizeSmall),
                                            Text('Close'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  body: _selectedSeason > league.seasonNumber
                      ? ErrorWithBackButton(
                          errorMessage:
                              'Selected season ${_selectedSeason} is greater than the current season ${league.seasonNumber}. Please select a valid season.',
                        )
                      : MaxWidthContainer(
                          child: DefaultTabController(
                            length: 3,
                            child: Column(
                              children: [
                                TabBar(
                                  tabs: [
                                    buildTabWithIcon(
                                        icon: Icons.format_list_numbered,
                                        text: 'Rankings'),
                                    buildTabWithIcon(
                                        icon: Icons.event, text: 'Games'),
                                    buildTabWithIcon(
                                        icon: iconStats, text: 'Stats'),
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
