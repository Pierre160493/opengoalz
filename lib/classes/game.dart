import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/club_page.dart';

part 'game_widget_helper.dart';

class Game {
  Game({
    required this.id,
    required this.idClub,
    required this.dateStart,
    required this.weekNumber,
    required this.idClubLeft,
    required this.nameClubLeft,
    required this.idClubRight,
    required this.nameClubRight,
    required this.idStadium,
    required this.isPlayed,
    required this.isCup,
    required this.goalsLeft,
    required this.goalsRight,
    required this.idUserClubLeft,
    required this.usernameClubLeft,
    required this.idUserClubRight,
    required this.usernameClubRight,
    required this.idPlayerGKLeft,
    required this.idPlayerLBLeft,
    required this.idPlayerLCBLeft,
    required this.idPlayerCBLeft,
    required this.idPlayerRCBLeft,
    required this.idPlayerRBLeft,
    required this.idPlayerLWLeft,
    required this.idPlayerLCMLeft,
    required this.idPlayerCMLeft,
    required this.idPlayerRCMLeft,
    required this.idPlayerRWLeft,
    required this.idPlayerLSLeft,
    required this.idPlayerCSLeft,
    required this.idPlayerRSLeft,
  });

  final int id;
  final int idClub;
  final DateTime dateStart;
  final int weekNumber;
  final int idClubLeft;
  final String nameClubLeft;
  final int idClubRight;
  final String nameClubRight;
  final int? idStadium;
  final bool isPlayed;
  final bool isCup;
  final int? goalsLeft;
  final int? goalsRight;
  final String? idUserClubLeft;
  final String? usernameClubLeft;
  final String? idUserClubRight;
  final String? usernameClubRight;

  // New player IDs on the left side
  final int? idPlayerGKLeft;
  final int? idPlayerLBLeft;
  final int? idPlayerLCBLeft;
  final int? idPlayerCBLeft;
  final int? idPlayerRCBLeft;
  final int? idPlayerRBLeft;
  final int? idPlayerLWLeft;
  final int? idPlayerLCMLeft;
  final int? idPlayerCMLeft;
  final int? idPlayerRCMLeft;
  final int? idPlayerRWLeft;
  final int? idPlayerLSLeft;
  final int? idPlayerCSLeft;
  final int? idPlayerRSLeft;

  Game.fromMap({required Map<String, dynamic> map})
      : id = map['id'],
        idClub = map['id_club'],
        dateStart = DateTime.parse(map['date_start']),
        weekNumber = map['week_number'],
        idClubLeft = map['id_club_left'],
        nameClubLeft = map['name_club_left'],
        idUserClubLeft = map['id_user_club_left'],
        usernameClubLeft = map['username_club_left'],
        goalsLeft = map['goals_left'],
        idClubRight = map['id_club_right'],
        nameClubRight = map['name_club_right'],
        idUserClubRight = map['id_user_club_right'],
        usernameClubRight = map['username_club_right'],
        goalsRight = map['goals_right'],
        idStadium = map['id_stadium'],
        isPlayed = map['is_played'] ?? false,
        isCup = map['is_cup'] ?? false,
        idPlayerGKLeft = map['id_player_GK_left'],
        idPlayerLBLeft = map['id_player_LB_left'],
        idPlayerLCBLeft = map['id_player_LCB_left'],
        idPlayerCBLeft = map['id_player_CB_left'],
        idPlayerRCBLeft = map['id_player_RCB_left'],
        idPlayerRBLeft = map['id_player_RB_left'],
        idPlayerLWLeft = map['id_player_LW_left'],
        idPlayerLCMLeft = map['id_player_LCM_left'],
        idPlayerCMLeft = map['id_player_CM_left'],
        idPlayerRCMLeft = map['id_player_RCM_left'],
        idPlayerRWLeft = map['id_player_RW_left'],
        idPlayerLSLeft = map['id_player_LS_left'],
        idPlayerCSLeft = map['id_player_CS_left'],
        idPlayerRSLeft = map['id_player_RS_left'];
}
