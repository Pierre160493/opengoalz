import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/models/mail.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/games_page.dart';
import 'package:opengoalz/pages/league_page.dart';
import 'package:opengoalz/pages/transfer_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:provider/provider.dart';

part 'clubWidgetHelper.dart';

class Club {
  List<TeamComp> teamComps = []; // List of the teamcomps of the club
  List<TeamComp> defaultTeamComps = []; // List of the teamcomps of the club
  List<Game> games = []; // Games of this club
  List<Player> players = []; // List of players of the club
  List<Mail> mails = []; // List of mails for the club
  Multiverse? multiverse; // Multiverse of the club
  League? league; // League of the club
  int points = 0; // Points of the club
  int victories = 0; // Victories of the club
  int draws = 0; // Draws of the club
  int defeats = 0; // Defeats of the club
  int goalsScored = 0; // Goals scored of the club
  int goalsTaken = 0; // Goals taken of the club

  bool isBelongingToConnectedUser =
      false; // If the club belongs to the current user
  bool isCurrentlySelected = false; // If the club is currently selected

  Club({
    required this.id,
    required this.createdAt,
    required this.userSince,
    required this.idMultiverse,
    required this.idLeague,
    required this.userName,
    required this.name,
    required this.cash,
    required this.lisCash,
    required this.revenuesSponsors,
    required this.revenuesSponsorsLastSeason,
    required this.lisRevenuesSponsors,
    required this.revenuesTotal,
    required this.lisRevenues,
    required this.expensesTotal,
    required this.lisExpenses,
    required this.expensesPlayersRatio,
    required this.expensesPlayers,
    required this.lisExpensesPlayers,
    required this.expensesStaffTarget,
    required this.expensesStaffApplied,
    required this.lisExpensesStaff,
    required this.expensesTax,
    required this.lisExpensesTax,
    required this.staffWeight,
    required this.lisStaffWeight,
    required this.numberFans,
    required this.idCountry,
    required this.leaguePoints,
    required this.lisLastResults,
    required this.posLeague,
    required this.seasonNumber,
    required this.idLeagueNextSeason,
    this.posLeagueNextSeason,
    required this.posLastSeason,
    required this.canUpdateName,
    required this.continent,
    required this.playersExpanses,
    required this.expensesPlayersRatioTarget,
    required this.leagueGoalsFor,
    required this.leagueGoalsAgainst,
    required this.scoutsWeight,
    required this.expensesScoutsTarget,
    required this.lisScoutsWeight,
    required this.lisExpensesScouts,
    required this.expensesScoutsApplied,
    required this.expensesTransfersDone,
    required this.expensesTransfersExpected,
    required this.lisExpensesTransfers,
    required this.revenuesTransfersDone,
    required this.revenuesTransfersExpected,
    required this.lisRevenuesTransfers,
  });

  final int id;
  final DateTime createdAt;
  final DateTime? userSince;
  final int idMultiverse;
  final int idLeague;
  final String? userName;
  final String name;
  final int cash;
  final List<int> lisCash;
  final List<int> lisRevenues;
  final List<int> lisExpenses;
  final int revenuesSponsors;
  final int? revenuesSponsorsLastSeason;
  final int revenuesTotal;
  final int expensesPlayers;
  final double expensesPlayersRatio;
  final int expensesStaffTarget;
  final int expensesStaffApplied;
  final int expensesTax;
  final int expensesTotal;
  final double staffWeight;
  final int numberFans;
  final int idCountry;
  final double leaguePoints;
  final List<int> lisLastResults;
  final int posLeague;
  final int seasonNumber;
  final int? idLeagueNextSeason;
  final int? posLeagueNextSeason;
  final int? posLastSeason;
  final bool canUpdateName;
  final String continent;
  final int playersExpanses;
  final double expensesPlayersRatioTarget;
  final int leagueGoalsFor;
  final int leagueGoalsAgainst;
  final List<int> lisExpensesStaff;
  final List<int> lisExpensesPlayers;
  final List<int> lisExpensesTax;
  final List<int> lisStaffWeight;
  final List<int> lisRevenuesSponsors;
  final double scoutsWeight;
  final int expensesScoutsTarget;
  final List<int> lisScoutsWeight;
  final List<int> lisExpensesScouts;
  final int expensesScoutsApplied;
  final int expensesTransfersDone;
  final int expensesTransfersExpected;
  final List<int> lisExpensesTransfers;
  final int revenuesTransfersDone;
  final int revenuesTransfersExpected;
  final List<int> lisRevenuesTransfers;

  Club.fromMap(Map<String, dynamic> map,
      {List<int>? myClubsIds, int? idSelectedClub})
      : id = map['id'],
        isBelongingToConnectedUser = myClubsIds?.contains(map['id']) ?? false,
        isCurrentlySelected = idSelectedClub == map['id'],
        createdAt = DateTime.parse(map['created_at']).toLocal(),
        userSince = map['user_since'] != null
            ? DateTime.parse(map['user_since']).toLocal()
            : null,
        idMultiverse = map['id_multiverse'],
        idLeague = map['id_league'],
        userName = map['username'],
        name = map['name'],
        cash = map['cash'],
        lisCash = List<int>.from(map['lis_cash']),
        lisRevenues = List<int>.from(map['lis_revenues']),
        lisExpenses = List<int>.from(map['lis_expenses']),
        lisExpensesStaff = List<int>.from(map['lis_expenses_staff']),
        lisExpensesPlayers = List<int>.from(map['lis_expenses_players']),
        lisExpensesTax = List<int>.from(map['lis_expenses_tax']),
        lisStaffWeight = List<int>.from(map['lis_staff_weight']),
        lisRevenuesSponsors = List<int>.from(map['lis_revenues_sponsors']),
        revenuesSponsors = map['revenues_sponsors'],
        revenuesSponsorsLastSeason = map['revenues_sponsors_last_season'],
        revenuesTotal = map['revenues_total'],
        expensesPlayers = map['expenses_players'],
        expensesPlayersRatio =
            (map['expenses_players_ratio'] as num).toDouble(),
        expensesStaffTarget = map['expenses_staff_target'],
        expensesStaffApplied = map['expenses_staff_applied'],
        expensesTax = map['expenses_tax'],
        expensesTotal = map['expenses_total'],
        staffWeight = (map['staff_weight'] as num).toDouble(),
        numberFans = map['number_fans'],
        idCountry = map['id_country'],
        leaguePoints = map['league_points'].toDouble(),
        lisLastResults = List<int>.from(map['lis_last_results']),
        posLeague = map['pos_league'],
        seasonNumber = map['season_number'],
        idLeagueNextSeason = map['id_league_next_season'],
        posLeagueNextSeason = map['pos_league_next_season'],
        posLastSeason = map['pos_last_season'],
        canUpdateName = map['can_update_name'],
        continent = map['continent'],
        playersExpanses = map['players_expanses'],
        expensesPlayersRatioTarget =
            (map['expenses_players_ratio_target'] as num).toDouble(),
        leagueGoalsFor = map['league_goals_for'],
        leagueGoalsAgainst = map['league_goals_against'],
        scoutsWeight = (map['scouts_weight'] as num).toDouble(),
        expensesScoutsTarget = map['expenses_scouts_target'],
        lisScoutsWeight = List<int>.from(map['lis_scouts_weight']),
        lisExpensesScouts = List<int>.from(map['lis_expenses_scouts']),
        expensesScoutsApplied = map['expenses_scouts_applied'],
        expensesTransfersDone = map['expenses_transfers_done'],
        expensesTransfersExpected = map['expenses_transfers_expected'],
        lisExpensesTransfers = List<int>.from(map['lis_expenses_transfers']),
        revenuesTransfersDone = map['revenues_transfers_done'],
        revenuesTransfersExpected = map['revenues_transfers_expected'],
        lisRevenuesTransfers = List<int>.from(map['lis_revenues_transfers']) {
    // print(
    //     'Club.fromMap: id=$id, createdAt=$createdAt, userSince=$userSince, idMultiverse=$idMultiverse, idLeague=$idLeague, userName=$userName, name=$name, cash=$cash, lisCash=$lisCash, lisRevenues=$lisRevenues, lisExpenses=$lisExpenses, lisExpensesStaff=$lisExpensesStaff, lisExpensesPlayers=$lisExpensesPlayers, lisExpensesTax=$lisExpensesTax, lisStaffWeight=$lisStaffWeight, lisRevenuesSponsors=$lisRevenuesSponsors, revenuesSponsors=$revenuesSponsors, revenuesSponsorsLastSeason=$revenuesSponsorsLastSeason, revenuesTotal=$revenuesTotal, expensesPlayers=$expensesPlayers, expensesPlayersRatio=$expensesPlayersRatio, expensesStaffTarget=$expensesStaffTarget, expensesStaffApplied=$expensesStaffApplied, expensesTax=$expensesTax, expensesTotal=$expensesTotal, staffWeight=$staffWeight, numberFans=$numberFans, idCountry=$idCountry, leaguePoints=$leaguePoints, lisLastResults=$lisLastResults, posLeague=$posLeague, seasonNumber=$seasonNumber, idLeagueNextSeason=$idLeagueNextSeason, posLeagueNextSeason=$posLeagueNextSeason, posLastSeason=$posLastSeason, canUpdateName=$canUpdateName, continent=$continent, playersExpanses=$playersExpanses, expensesPlayersRatioTarget=$expensesPlayersRatioTarget, leagueGoalsFor=$leagueGoalsFor, leagueGoalsAgainst=$leagueGoalsAgainst, scoutsWeight=$scoutsWeight, expensesScoutsTarget=$expensesScoutsTarget, lisScoutsWeight=$lisScoutsWeight, lisExpensesScouts=$lisExpensesScouts, expensesScoutsApplied=$expensesScoutsApplied, expensesTransfersDone=$expensesTransfersDone, expensesTransfersExpected=$expensesTransfersExpected, lisExpensesTransfers=$lisExpensesTransfers, revenuesTransfersDone=$revenuesTransfersDone, revenuesTransfersExpected=$revenuesTransfersExpected, lisRevenuesTransfers=$lisRevenuesTransfers');
  }

  /// Fetch the club from its id
  static Future<Club?> fromId(int id) async {
    final stream = supabase
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((maps) => maps.map((map) => Club.fromMap(map)).first);

    try {
      final club = await stream.first;
      return club;
    } catch (e) {
      print('Error fetching club: $e');
      return null;
    }
  }
}
