import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/events/event.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/player/players_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'gameClass_widget_helper.dart';
part 'gameClass_widget_teamcomp.dart';

class GameClass {
  List<GameEvent> events = []; //list of events in the game
  late Club leftClub; //left club
  late Club rightClub; //left club

  GameClass({
    required this.id,
    required this.idClubLeft,
    required this.idClubRight,
    required this.dateStart,
    required this.idStadium,
    required this.weekNumber,
    required this.isPlayed,
    required this.isCup,
    required this.isLeague,
    required this.isFriendly,
  });

  final int id;
  final int idClubLeft;
  final int idClubRight;
  final DateTime dateStart;
  final int? idStadium;
  final int? weekNumber;
  final bool isPlayed;
  final bool isCup;
  final bool isLeague;
  final bool isFriendly;

  factory GameClass.fromMap(Map<String, dynamic> map) {
    return GameClass(
      id: map['id'],
      idClubLeft: map['id_club_left'],
      idClubRight: map['id_club_right'],
      dateStart: DateTime.parse(map['date_start']),
      idStadium: map['id_stadium'],
      weekNumber: map['week_number'],
      isPlayed: map['is_played'] ?? false,
      isCup: map['is_cup'] ?? false,
      isLeague: map['is_league_game'] ?? false,
      isFriendly: map['is_friendly'] ?? false,
    );
  }
}
