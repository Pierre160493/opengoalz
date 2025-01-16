import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/clubHelper.dart';
import 'package:opengoalz/models/events/event.dart';
import 'package:opengoalz/models/game/scoreWidget.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/widgets/graphWidget.dart';

part 'game_widget_helper.dart';

class Game {
  List<GameEvent> events = []; //list of events in the game
  late Club leftClub; //left club
  late Club rightClub; //left club
  String description =
      'ERROR: Game description not found !'; //description of the game
  bool? isLeftClubSelected;

  Game({
    required this.id,
    required this.idClubLeft,
    required this.idClubRight,
    required this.isPlaying,
    required this.dateStart,
    required this.dateEnd,
    required this.idStadium,
    required this.weekNumber,
    required this.isCup,
    required this.isLeague,
    required this.isFriendly,
    required this.idLeague,
    required this.idMultiverse,
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
    required this.idDescription,
    required this.scorePreviousLeft,
    required this.scorePreviousRight,
    required this.scorePenaltyLeft,
    required this.scorePenaltyRight,
    required this.scoreCumulWithPenaltyLeft,
    required this.scoreCumulWithPenaltyRight,
    required this.isLeftClubOverallWinner,
    this.isLeftClubSelected,
    required this.expectedEloResult,
    required this.isLeftForfeit,
    required this.isRightForfeit,
    required this.eloLeft,
    required this.eloRight,
  });

  final int id;
  final int? idClubLeft;
  final int? idClubRight;
  final bool? isPlaying;
  final DateTime dateStart;
  final DateTime? dateEnd;
  final String? idStadium;
  final int weekNumber;
  final bool isCup;
  final bool isLeague;
  final bool isFriendly;
  final int? idLeague;
  final int idMultiverse;
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
  final int idDescription;
  final int? scorePreviousLeft;
  final int? scorePreviousRight;
  final int? scorePenaltyLeft;
  final int? scorePenaltyRight;
  final double? scoreCumulWithPenaltyLeft;
  final double? scoreCumulWithPenaltyRight;
  final bool? isLeftClubOverallWinner;
  final List<double>? expectedEloResult;
  final bool isLeftForfeit;
  final bool isRightForfeit;
  final int? eloLeft;
  final int? eloRight;

  factory Game.fromMap(Map<String, dynamic> map, int? idClubSelected) {
    bool? isLeftClubSelected;
    if (map['id_club_left'] == idClubSelected) {
      isLeftClubSelected = true;
    } else if (map['id_club_right'] == idClubSelected) {
      isLeftClubSelected = false;
    }

    return Game(
      id: map['id'],
      idClubLeft: map['id_club_left'],
      idClubRight: map['id_club_right'],
      isPlaying: map['is_playing'],
      dateStart: map['date_start'] != null
          ? DateTime.parse(map['date_start']).toLocal()
          : throw ArgumentError('date_start cannot be null'),
      dateEnd: map['date_end'] != null
          ? DateTime.parse(map['date_end']).toLocal()
          : null,
      idStadium: map['id_stadium'],
      weekNumber: map['week_number'],
      isCup: map['is_cup'] ?? false,
      isLeague: map['is_league'] ?? false,
      isFriendly: map['is_friendly'] ?? false,
      idLeague: map['id_league'],
      idMultiverse: map['id_multiverse'],
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
      idDescription: map['id_games_description'],
      isLeftClubSelected: isLeftClubSelected,
      scorePreviousLeft: map['score_previous_left'],
      scorePreviousRight: map['score_previous_right'],
      scorePenaltyLeft: map['score_penalty_left'],
      scorePenaltyRight: map['score_penalty_right'],
      scoreCumulWithPenaltyLeft:
          (map['score_cumul_with_penalty_left'] as num?)?.toDouble(),
      scoreCumulWithPenaltyRight:
          (map['score_cumul_with_penalty_right'] as num?)?.toDouble(),
      isLeftClubOverallWinner: map['is_left_club_overall_winner'],
      expectedEloResult: (map['expected_elo_result'] as List<dynamic>?)
              ?.where((e) => e != null)
              .map((e) => (e as num).toDouble())
              .toList() ??
          [],
      isLeftForfeit: map['is_left_forfeit'] ?? false,
      isRightForfeit: map['is_right_forfeit'] ?? false,
      eloLeft: map['elo_left'],
      eloRight: map['elo_right'],
    );
  }
}
