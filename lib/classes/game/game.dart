import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/events/event.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/classes/player/players_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'game_widget_helper.dart';
part 'game_widget_teamcomp.dart';

class Game {
  List<GameEvent> events = []; //list of events in the game
  late Club leftClub; //left club
  late Club rightClub; //left club
  int? leftScore = null; //left club score
  int? rightScore = null; //right club score

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
    required this.isLeagueGame,
    required this.isFriendly,
    required this.idLeague,
    required this.multiverseSpeed,
    required this.seasonNumber,
  });

  final int id;
  final int idClubLeft;
  final int idTeamcompLeft;
  final int idClubRight;
  final int idTeamcompRight;
  final DateTime dateStart;
  final String?
      idStadium; // In your SQL, id_stadium is of type UUID which is a string in Dart
  final int? weekNumber;
  final bool isPlayed;
  final bool isCup;
  final bool isLeagueGame;
  final bool isFriendly;
  final int? idLeague;
  final int multiverseSpeed;
  final int seasonNumber;

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
      isLeagueGame: map['is_league_game'] ?? false,
      isFriendly: map['is_friendly'] ?? false,
      idLeague: map['id_league'],
      multiverseSpeed: map['multiverse_speed'],
      seasonNumber: map['season_number'],
    );
  }
}
