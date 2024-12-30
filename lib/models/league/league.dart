import 'dart:math';
import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/events/event.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/pages/league_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'leagueWidgetHelper.dart';
part 'leagueMainTab.dart';
part 'leagueGamesTab.dart';
part 'leagueStatsTab.dart';

class League {
  List<Game> games = []; // List of games in the league
  List<Club> clubsAll =
      []; // All clubs that played in the league + qualification games
  List<Club> clubsLeague = []; // All 6 clubs in the league
  int? idSelectedClub; // id of the club selected in the club tab

  League({
    required this.id,
    required this.idMultiverse,
    required this.seasonNumber,
    required this.continent,
    required this.level,
    required this.number,
    required this.idUpperLeague,
    required this.idLowerLeague,
    required this.isFinished,
  });

  final int id;
  final int idMultiverse;
  final int seasonNumber;
  final String continent;
  final int level;
  final int number;
  final int? idUpperLeague;
  final int? idLowerLeague;
  final bool? isFinished;

  League.fromMap(Map<String, dynamic> map,
      {this.idSelectedClub}) // Add idSelectedClub as an optional parameter
      : id = map['id'],
        idMultiverse = map['id_multiverse'],
        seasonNumber = map['season_number'],
        continent = map['continent'],
        level = map['level'],
        number = map['number'],
        idUpperLeague = map['id_upper_league'],
        idLowerLeague = map['id_lower_league'],
        isFinished = map['is_finished'];
}
