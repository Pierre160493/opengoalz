// import 'dart:ffi';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:collection/collection.dart';
// import 'package:opengoalz/classes/club/club.dart';
// import 'package:opengoalz/classes/events/event.dart';
// import 'package:opengoalz/classes/game/class/game.dart';
// import 'package:opengoalz/classes/player/class/player.dart';
// import 'package:opengoalz/classes/player/players_page.dart';
// import 'package:opengoalz/constants.dart';
// import 'package:opengoalz/pages/club_page.dart';
// import 'package:opengoalz/pages/game_page.dart';
// import 'package:opengoalz/pages/league_page.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// part 'leagueWidgetHelper.dart';
// part 'leagueMainTab.dart';
// part 'leagueGamesTab.dart';
// part 'leagueStatsTab.dart';

// class League {
//   List<Game> games = [];
//   List<Club> clubs = [];

//   League({
//     required this.id,
//     required this.multiverseSpeed,
//     required this.seasonNumber,
//     required this.continent,
//     required this.level,
//     required this.number,
//     required this.idUpperLeague,
//     required this.isFinished,
//   });

//   final int id;
//   final int multiverseSpeed;
//   final int seasonNumber;
//   final String continent;
//   final int level;
//   final int number;
//   final int? idUpperLeague;
//   final bool isFinished;

//   League.fromMap(Map<String, dynamic> map)
//       : id = map['id'],
//         multiverseSpeed = map['multiverse_speed'],
//         seasonNumber = map['season_number'],
//         continent = map['continent'],
//         level = map['level'],
//         number = map['number'],
//         idUpperLeague = map['id_upper_league'],
//         isFinished = map['is_finished'];
// }
