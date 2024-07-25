import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/events/event.dart';
import 'package:opengoalz/pages/game_page.dart';

part 'game_widget_helper.dart';
// part 'game_widget_teamcomp.dart';

class Game {
  List<GameEvent> events = []; //list of events in the game
  late Club leftClub; //left club
  late Club rightClub; //left club

  Game({
    required this.id,
    required this.idClubLeft,
    required this.idTeamcompLeft,
    required this.idClubRight,
    required this.idTeamcompRight,
    required this.dateStart,
    required this.idStadium,
    required this.weekNumber,
    required this.isPlayed,
    required this.isCup,
    required this.isLeague,
    required this.isFriendly,
    required this.idLeague,
    required this.multiverseSpeed,
    required this.seasonNumber,
    required this.isRelegation,
    required this.posLeftClub,
    required this.posRightClub,
    required this.idLeagueLeftClub,
    required this.idLeagueRightClub,
    required this.idGameLeftClub,
    required this.idGameRightClub,
    required this.isReturnGameIdGameFirstRound,
    required this.error,
    required this.scoreLeft,
    required this.scoreRight,
    required this.scoreCumulLeft,
    required this.scoreCumulRight,
    required this.description,
  });

  final int id;
  final int? idClubLeft;
  final int? idTeamcompLeft;
  final int? idClubRight;
  final int? idTeamcompRight;
  final DateTime dateStart;
  final String? idStadium;
  final int weekNumber;
  final bool isPlayed;
  final bool isCup;
  final bool isLeague;
  final bool isFriendly;
  final int? idLeague;
  final int multiverseSpeed;
  final int seasonNumber;
  final bool isRelegation;
  final int? posLeftClub;
  final int? posRightClub;
  final int? idLeagueLeftClub;
  final int? idLeagueRightClub;
  final int? idGameLeftClub;
  final int? idGameRightClub;
  final int? isReturnGameIdGameFirstRound;
  final String? error;
  final int? scoreLeft;
  final int? scoreRight;
  final double? scoreCumulLeft;
  final double? scoreCumulRight;
  final String description;

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'],
      idClubLeft: map['id_club_left'],
      idTeamcompLeft: map['id_teamcomp_left'],
      idClubRight: map['id_club_right'],
      idTeamcompRight: map['id_teamcomp_right'],
      dateStart: map['date_start'] != null
          ? DateTime.parse(map['date_start'])
          : throw ArgumentError('date_start cannot be null'),
      idStadium: map['id_stadium'],
      weekNumber: map['week_number'],
      isPlayed: map['is_played'] ?? false,
      isCup: map['is_cup'] ?? false,
      isLeague: map['is_league'] ?? false,
      isFriendly: map['is_friendly'] ?? false,
      idLeague: map['id_league'],
      multiverseSpeed: map['multiverse_speed'],
      seasonNumber: map['season_number'],
      isRelegation: map['is_relegation'] ?? false,
      posLeftClub: map['pos_club_left'],
      posRightClub: map['pos_club_right'],
      idLeagueLeftClub: map['id_league_club_left'],
      idLeagueRightClub: map['id_league_club_right'],
      idGameLeftClub: map['id_game_club_left'],
      idGameRightClub: map['id_game_club_right'],
      isReturnGameIdGameFirstRound: map['is_return_game_id_game_first_round'],
      error: map['error'],
      scoreLeft: map['score_left'],
      scoreRight: map['score_right'],
      scoreCumulLeft: map['score_cumul_left'] != null
          ? (map['score_cumul_left'] as num).toDouble()
          : null,
      scoreCumulRight: map['score_cumul_right'] != null
          ? (map['score_cumul_right'] as num).toDouble()
          : null,
      description: map['description'],
    );
  }
}
