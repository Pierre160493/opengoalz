import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:supabase/supabase.dart';

class ClubData {
  ClubData({
    required this.numberFans,
    required this.posLeague,
    required this.staffWeight,
    required this.cash,
    required this.expensesTrainingApplied,
    required this.expensesPlayers,
    required this.expensesStaff,
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
    required this.eloPoints,
    required this.expensesPlayersRatioTarget,
    required this.expensesPlayersRatio,
    required this.expensesTrainingTarget,
    required this.expensesScoutsTarget,
  });

  final int numberFans;
  final int posLeague;
  final double staffWeight;
  final int cash;
  final int expensesTrainingApplied;
  final int expensesPlayers;
  final int expensesStaff;
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
  final int eloPoints;
  final double expensesPlayersRatioTarget;
  final double expensesPlayersRatio;
  final int expensesTrainingTarget;
  final int expensesScoutsTarget;

  ClubData.fromMap(Map<String, dynamic> map)
      : numberFans = map['number_fans'],
        posLeague = map['pos_league'],
        staffWeight = (map['training_weight'] as num).toDouble(),
        cash = map['cash'],
        expensesTrainingApplied = map['expenses_training_applied'],
        expensesPlayers = map['expenses_players'],
        expensesStaff = map['expenses_staff'],
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
        eloPoints = map['elo_points'],
        expensesPlayersRatioTarget =
            (map['expenses_players_ratio_target'] as num).toDouble(),
        expensesPlayersRatio =
            (map['expenses_players_ratio'] as num).toDouble(),
        expensesTrainingTarget = map['expenses_training_target'],
        expensesScoutsTarget = map['expenses_scouts_target'];

  // Method to stream club data history from Supabase
  static Stream<List<ClubData>> streamClubDataHistory(int clubId) {
    return supabase
        .from('clubs_history_weekly')
        .stream(primaryKey: ['id'])
        .eq('id_club', clubId)
        .order('week_number')
        .order('season_number', ascending: true)
        .map((maps) {
          maps.forEach((map) {});
          return maps.map((map) => ClubData.fromMap(map)).toList();
        });
  }

  // Method to show club history dialog box
  static Future<void> showClubDataHistoryChartDialog(
      BuildContext context, int idClub, String columnName, String titleName,
      {var dataToAppend = null}) async {
    final List<num>? dataHistory =
        await fetchClubDataHistory(context, idClub, columnName);

    if (dataHistory != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final chartData = ChartData(
            title: titleName,
            yValues: [
              if (dataToAppend != null)
                [...dataHistory, dataToAppend]
              else
                dataHistory
            ],
            typeXAxis: XAxisType.weekHistory,
          );

          return ChartDialogBox(chartData: chartData);
        },
      );
    }
  }

  // Method to fetch club data history from Supabase
  static Future<List<num>?> fetchClubDataHistory(
      BuildContext context, int clubId, String dataToFetch) async {
    try {
      final response = await supabase
          .from('clubs_history_weekly')
          .select(dataToFetch)
          // .select('id')
          .eq('id_club', clubId)
          .order('season_number', ascending: true)
          .order('week_number', ascending: true);
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

  // Add this operator to allow property access by string key
  dynamic operator [](String key) {
    switch (key) {
      case 'number_fans':
        return numberFans;
      case 'pos_league':
        return posLeague;
      case 'training_weight':
        return staffWeight;
      case 'cash':
        return cash;
      case 'expenses_training_applied':
        return expensesTrainingApplied;
      case 'expenses_players':
        return expensesPlayers;
      case 'expenses_staff':
        return expensesStaff;
      case 'expenses_total':
        return expensesTotal;
      case 'revenues_sponsors':
        return revenuesSponsors;
      case 'revenues_total':
        return revenuesTotal;
      case 'expenses_tax':
        return expensesTax;
      case 'league_points':
        return leaguePoints;
      case 'league_goals_for':
        return leagueGoalsFor;
      case 'league_goals_against':
        return leagueGoalsAgainst;
      case 'scouts_weight':
        return scoutsWeight;
      case 'expenses_scouts_applied':
        return expensesScoutsApplied;
      case 'expenses_transfers_done':
        return expensesTransfersDone;
      case 'revenues_transfers_done':
        return revenuesTransfersDone;
      case 'elo_points':
        return eloPoints;
      case 'expenses_players_ratio_target':
        return expensesPlayersRatioTarget;
      case 'expenses_players_ratio':
        return expensesPlayersRatio;
      case 'expenses_training_target':
        return expensesTrainingTarget;
      case 'expenses_scouts_target':
        return expensesScoutsTarget;
      case 'week_number':
        return null;
      case 'id_club':
        return null;
      default:
        return null;
    }
  }
}
