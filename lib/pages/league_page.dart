import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/events/event.dart';
import 'package:opengoalz/classes/league/league.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/classes/game/class/game.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';

import '../constants.dart';

class LeaguePage extends StatefulWidget {
  final int idLeague; // Add idLeague as an input parameter
  const LeaguePage({Key? key, required this.idLeague}) : super(key: key);

  static Route<void> route(int idLeague) {
    return MaterialPageRoute<void>(
      builder: (context) => LeaguePage(idLeague: idLeague),
    );
  }

  @override
  State<LeaguePage> createState() => _RankingPageState();
}

class _RankingPageState extends State<LeaguePage> {
  late Stream<League> _leagueStream;

  @override
  void initState() {
    // Fetch the league data
    _leagueStream = supabase
        .from('leagues')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idLeague) // Access idLeague via widget
        .map((maps) => maps.map((map) => League.fromMap(map)).first)
        .switchMap((League league) {
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('id_league', league.id)
              .map((maps) => maps.map((map) => Club.fromMap(map: map)).toList())
              .map((clubs) {
                for (Club club in clubs) {
                  league.clubs.add(club);
                }
                return league;
              });
        })
        .switchMap((League league) {
          return supabase
              .from('games')
              .stream(primaryKey: ['id'])
              .eq('id_league', league.id)
              .map((maps) => maps.map((map) => Game.fromMap(map)).toList())
              .map((games) {
                league.games = games
                    .where(
                        (Game game) => game.seasonNumber == league.seasonNumber)
                    .toList(); // Add all the games of this league
                league.games.sort((a, b) => a.dateStart.compareTo(b.dateStart));
                for (Game game in league.games) {
                  game.leftClub = league.clubs.firstWhere(
                      (club) => club.id == game.idClubLeft,
                      orElse: () => throw Exception(
                          'DATABASE ERROR: Club not found for the left club with id: ${game.idClubLeft} for the game with id: ${game.id}'));
                  ;
                  game.rightClub = league.clubs.firstWhere(
                      (club) => club.id == game.idClubRight,
                      orElse: () => throw Exception(
                          'DATABASE ERROR: Club not found for the right club with id: ${game.idClubRight} for the game with id: ${game.id}'));
                  ;
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
                      (map) => map['id'] == game.idDescription)['description'];
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
              .map((events) {
                for (Game game in league.games) {
                  game.events = events
                      .where((GameEvent event) => event.idGame == game.id)
                      .toList();
                  if (game.dateEnd != null) {
                    // Update the goals scored and points of the clubs
                    league.clubs
                        .firstWhere((club) => club.id == game.idClubLeft)
                        .goalsScored += game.scoreLeft!;
                    league.clubs
                        .firstWhere((club) => club.id == game.idClubRight)
                        .goalsTaken += game.scoreLeft!;
                    league.clubs
                        .firstWhere((club) => club.id == game.idClubLeft)
                        .goalsTaken += game.scoreRight!;
                    league.clubs
                        .firstWhere((club) => club.id == game.idClubRight)
                        .goalsScored += game.scoreRight!;
                    // Update the points of the clubs
                    if (game.scoreLeft! > game.scoreRight!) {
                      // Left victory
                      league.clubs
                          .firstWhere((club) => club.id == game.idClubLeft)
                          .points += 3;
                      league.clubs
                          .firstWhere((club) => club.id == game.idClubLeft)
                          .victories += 1;
                      league.clubs
                          .firstWhere((club) => club.id == game.idClubRight)
                          .defeats += 1;
                    } else if (game.scoreLeft! < game.scoreRight!) {
                      // Right Victory
                      league.clubs
                          .firstWhere((club) => club.id == game.idClubLeft)
                          .defeats += 1;
                      league.clubs
                          .firstWhere((club) => club.id == game.idClubRight)
                          .victories += 1;
                      league.clubs
                          .firstWhere((club) => club.id == game.idClubRight)
                          .points += 3;
                    } else {
                      // Draw
                      league.clubs
                          .firstWhere((club) => club.id == game.idClubLeft)
                          .draws += 1;
                      league.clubs
                          .firstWhere((club) => club.id == game.idClubLeft)
                          .points += 1;
                      league.clubs
                          .firstWhere((club) => club.id == game.idClubRight)
                          .draws += 1;
                      league.clubs
                          .firstWhere((club) => club.id == game.idClubRight)
                          .points += 1;
                    }
                  }
                }
                // order league clubs by number of points
                league.clubs.sort((a, b) {
                  int compare = b.points.compareTo(a.points);
                  if (compare != 0) {
                    return compare;
                  } else {
                    return (b.goalsScored - b.goalsTaken)
                        .compareTo(a.goalsScored - a.goalsTaken);
                  }
                });
                return league;
              });
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<League>(
        stream: _leagueStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('ERROR: ${snapshot.error}'),
            );
          } else {
            League league = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                    'League ${league.level.toString()}.${league.number.toString()} of ${league.continent}'),
              ),
              drawer: const AppDrawer(),
              body: MaxWidthContainer(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          buildTab(Icons.format_list_numbered, 'Rankings'),
                          buildTab(Icons.event, 'Games'),
                          buildTab(Icons.query_stats, 'Stats'),
                          // buildTab(Icons.wechat, 'Chat'),
                        ],
                      ),
                      Expanded(
                          child: TabBarView(
                        children: [
                          league.leagueMainTab(context),
                          league.leagueGamesTab(context),
                          league.leagueStatsTab(context),
                          // Center(
                          //     child: Text('League Chat (Not yet implemented)')),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
