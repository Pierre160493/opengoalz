//ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/game/class/game.dart';
import 'package:opengoalz/classes/league/league.dart';
import 'package:opengoalz/classes/player/players_page.dart';
import 'package:opengoalz/classes/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/games_page.dart';
import 'package:opengoalz/pages/league_page.dart';
import 'package:opengoalz/pages/transfer_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'clubWidgetTeamcomp.dart';
part 'clubWidgetHelper.dart';
part 'clubWidgetFinances.dart';

class Club {
  List<TeamComp> teamComps = []; //List of the teamcomps of the club
  List<TeamComp> defaultTeamComps = []; //List of the teamcomps of the club
  List<Game> games = []; //games of this club
  List<Player> players = []; // List of players of the club
  League? league; // League of the club
  int points = 0; // points of the club
  int victories = 0; // victories of the club
  int draws = 0; // draws of the club
  int defeats = 0; // defeats of the club
  int goalsScored = 0; // goals scored of the club
  int goalsTaken = 0; // goals taken of the club

  bool isBelongingToConnectedUser =
      false; // If the club belongs to the current user
  bool isCurrentlySelected = false; // If the club is currently selected

  Club({
    required this.id,
    required this.createdAt,
    required this.multiverseSpeed,
    required this.idLeague,
    required this.userName,
    required this.name,
    required this.staffExpanses,
    required this.lisCash,
    required this.lisRevenues,
    required this.lisSponsors,
    required this.lisExpanses,
    required this.lisTax,
    required this.lisPlayersExpanses,
    required this.lisStaffExpanses,
    required this.staffWeight,
    required this.numberFans,
    required this.idCountry,
    required this.leaguePoints,
    required this.lisLastResults,
    required this.posLeague,
    required this.seasonNumber,
    required this.idLeagueNextSeason,
    this.posLeagueNextSeason,
  });

  final int id;
  final DateTime createdAt;
  final int multiverseSpeed;
  final int idLeague;
  final String? userName;
  final String name;
  final int staffExpanses;
  final List<int> lisCash;
  final List<int> lisRevenues;
  final List<int> lisSponsors;
  final List<int> lisExpanses;
  final List<int> lisTax;
  final List<int> lisPlayersExpanses;
  final List<int> lisStaffExpanses;
  final double staffWeight;
  final int numberFans;
  final int idCountry;
  final double leaguePoints;
  final List<int> lisLastResults;
  final int posLeague;
  final int seasonNumber;
  final int? idLeagueNextSeason;
  final int? posLeagueNextSeason;

  Club.fromMap(Map<String, dynamic> map,
      {List<int>? myClubsIds, int? idSelectedClub})
      : id = map['id'],
        isBelongingToConnectedUser = myClubsIds?.contains(map['id']) ??
            false, // Set isUser to true if the club id is in myClubsIds
        isCurrentlySelected =
            idSelectedClub == map['id'], // Is the club selected
        createdAt = DateTime.parse(map['created_at']),
        multiverseSpeed = map['multiverse_speed'],
        idLeague = map['id_league'],
        userName = map['username'],
        name = map['name_club'],
        staffExpanses = map['staff_expanses'],
        lisCash = List<int>.from(map['lis_cash']),
        lisRevenues = List<int>.from(map['lis_revenues']),
        lisSponsors = List<int>.from(map['lis_sponsors']),
        lisExpanses = List<int>.from(map['lis_expanses']),
        lisTax = List<int>.from(map['lis_tax']),
        lisPlayersExpanses = List<int>.from(map['lis_players_expanses']),
        lisStaffExpanses = List<int>.from(map['lis_staff_expanses']),
        staffWeight = (map['staff_weight'] as num).toDouble(),
        numberFans = map['number_fans'],
        idCountry = map['id_country'],
        leaguePoints = map['league_points'].toDouble(),
        lisLastResults = List<int>.from(map['lis_last_results']),
        posLeague = map['pos_league'],
        seasonNumber = map['season_number'],
        idLeagueNextSeason = map['id_league_next_season'],
        posLeagueNextSeason = map['pos_league_next_season'];
}
