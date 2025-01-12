import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:supabase/supabase.dart';

class ClubData {
  ClubData({
    required this.numberFans,
    required this.posLeague,
    required this.staffWeight,
    required this.cash,
    required this.expensesStaffApplied,
    required this.expensesPlayers,
    required this.expensesTotal,
    required this.revenuesSponsors,
    required this.revenuesTotal,
    required this.expensesTax,
    required this.leaguePoints,
    required this.leagueGoalsFor,
    required this.leagueGoalsAgainst,
    required this.scoutsWeight,
    required this.expensesScoutsApplied,
    required this.expensesTransfersDone,
    required this.revenuesTransfersDone,
    required this.rankingPoints,
    required this.expensesPlayersRatioTarget,
    required this.expensesPlayersRatio,
    required this.expensesStaffTarget,
    required this.expensesScoutsTarget,
  });

  final int numberFans;
  final int posLeague;
  final double staffWeight;
  final int cash;
  final int expensesStaffApplied;
  final int expensesPlayers;
  final int expensesTotal;
  final int revenuesSponsors;
  final int revenuesTotal;
  final int expensesTax;
  final int leaguePoints;
  final int leagueGoalsFor;
  final int leagueGoalsAgainst;
  final int scoutsWeight;
  final int expensesScoutsApplied;
  final int expensesTransfersDone;
  final int revenuesTransfersDone;
  final int rankingPoints;
  final double expensesPlayersRatioTarget;
  final double expensesPlayersRatio;
  final int expensesStaffTarget;
  final int expensesScoutsTarget;

  ClubData.fromMap(Map<String, dynamic> map)
      : numberFans = map['number_fans'],
        posLeague = map['pos_league'],
        staffWeight = (map['staff_weight'] as num).toDouble(),
        cash = map['cash'],
        expensesStaffApplied = map['expenses_staff_applied'],
        expensesPlayers = map['expenses_players'],
        expensesTotal = map['expenses_total'],
        revenuesSponsors = map['revenues_sponsors'],
        revenuesTotal = map['revenues_total'],
        expensesTax = map['expenses_tax'],
        leaguePoints = map['league_points'],
        leagueGoalsFor = map['league_goals_for'],
        leagueGoalsAgainst = map['league_goals_against'],
        scoutsWeight = map['scouts_weight'],
        expensesScoutsApplied = map['expenses_scouts_applied'],
        expensesTransfersDone = map['expenses_transfers_done'],
        revenuesTransfersDone = map['revenues_transfers_done'],
        rankingPoints = map['ranking_points'],
        expensesPlayersRatioTarget =
            (map['expenses_players_ratio_target'] as num).toDouble(),
        expensesPlayersRatio =
            (map['expenses_players_ratio'] as num).toDouble(),
        expensesStaffTarget = map['expenses_staff_target'],
        expensesScoutsTarget = map['expenses_scouts_target'];

  // Method to fetch club data history from Supabase
  static Future<List<num>?> fetchClubDataHistory(
      BuildContext context, int clubId, String dataToFetch) async {
    try {
      final response = await supabase
          .from('clubs_history_weekly')
          .select(dataToFetch)
          .eq('id_club', clubId)
          .order('season_number')
          .order('week_number');
      final List<num> values = (response as List<dynamic>)
          .map((item) => (item[dataToFetch] as num))
          .toList();
      return values;
    } on PostgrestException catch (error) {
      context.showSnackBarPostgreSQLError('PostgreSQL ERROR: ${error.message}');
    } catch (error) {
      context.showSnackBarError('Unknown ERROR: $error');
    }
    return null;
  }

  // Method to stream club data history from Supabase
  static Stream<List<ClubData>> streamClubDataHistory(int clubId) {
    return supabase
        .from('clubs_history_weekly')
        .stream(primaryKey: ['id'])
        .eq('id_club', clubId)
        .order('season_number')
        .order('week_number')
        .map((maps) {
          return maps.map((map) => ClubData.fromMap(map)).toList();
        });
  }
}
