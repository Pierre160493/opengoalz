import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/functions/stringFunctions.dart';
import 'package:opengoalz/models/club/class/club_data.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/models/mail.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/profile.dart';
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
    required this.clubData,
    required this.idCountry,
    required this.lisLastResults,
    required this.seasonNumber,
    required this.idLeagueNextSeason,
    this.posLeagueNextSeason,
    required this.posLastSeason,
    required this.canUpdateName,
    required this.continent,
    required this.revenuesSponsorsLastSeason,
    required this.revenuesTransfersExpected,
    required this.expensesTransfersExpected,
  });

  final int id;
  final DateTime createdAt;
  final DateTime? userSince;
  final int idMultiverse;
  final int idLeague;
  final String? userName;
  final String name;
  final ClubData clubData;
  final int idCountry;
  final List<int> lisLastResults;
  final int seasonNumber;
  final int? idLeagueNextSeason;
  final int? posLeagueNextSeason;
  final int? posLastSeason;
  final int revenuesSponsorsLastSeason;
  final int revenuesTransfersExpected;
  final int expensesTransfersExpected;
  final bool canUpdateName;
  final String continent;

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
        clubData = ClubData.fromMap(map),
        idCountry = map['id_country'],
        lisLastResults = List<int>.from(map['lis_last_results']),
        seasonNumber = map['season_number'],
        idLeagueNextSeason = map['id_league_next_season'],
        posLeagueNextSeason = map['pos_league_next_season'],
        posLastSeason = map['pos_last_season'],
        canUpdateName = map['can_update_name'],
        revenuesSponsorsLastSeason = map['revenues_sponsors_last_season'],
        revenuesTransfersExpected = map['revenues_transfers_expected'],
        expensesTransfersExpected = map['expenses_transfers_expected'],
        continent = map['continent'] {
    // print(map);
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
