import 'package:flutter/material.dart';
import 'package:opengoalz/functions/stringFunctions.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/pages/league_page/league_page.dart';

part 'league_extension.dart';

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
    required this.name,
  });

  final int id;
  final int idMultiverse;
  final String name;
  final String? continent;
  final int seasonNumber;
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
        isFinished = map['is_finished'],
        name = map['name'];
}
