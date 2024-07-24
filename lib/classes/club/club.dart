//ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/game/class/game.dart';
import 'package:opengoalz/classes/player/players_page.dart';
import 'package:opengoalz/classes/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'clubWidgetTeamcomp.dart';

class Club {
  TeamComp? teamcomp; //team composition
  List<TeamComp> teamcomps = []; //List of the teamcomps of the club
  List<Game> games = []; //games of this club
  List<Player> players = []; // List of players of the club
  int points = 0; // points of the club
  int victories = 0; // victories of the club
  int draws = 0; // draws of the club
  int defeats = 0; // defeats of the club
  int goalsScored = 0; // goals scored of the club
  int goalsTaken = 0; // goals taken of the club

  Club({
    required this.id,
    required this.createdAt,
    required this.multiverseSpeed,
    required this.continent,
    required this.idLeague,
    this.idUser,
    required this.nameClub,
    required this.cashAbsolute,
    required this.cashAvailable,
    required this.numberFans,
    required this.idCountry,
    this.posSeason,
    this.posLastSeason,
    this.leaguePointsArray,
    required this.leaguePoints,
    this.lastResultsArray,
    this.lastResult,
    required this.posLeague,
    required this.seasonNumber,
    required this.idLeagueNextSeason,
    this.posLeagueNextSeason,
  });

  final int id;
  final DateTime createdAt;
  final int multiverseSpeed;
  final String continent;
  final int idLeague;
  final String? idUser;
  final String nameClub;
  final int cashAbsolute;
  final int cashAvailable;
  final int numberFans;
  final int idCountry;
  final List<int>? posSeason;
  final int? posLastSeason;
  final List<double>? leaguePointsArray;
  final double leaguePoints;
  final List<int>? lastResultsArray;
  final int? lastResult;
  final int posLeague;
  final int seasonNumber;
  final int idLeagueNextSeason;
  final int? posLeagueNextSeason;

  Club.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id = map['id'],
        createdAt = DateTime.parse(map['created_at']),
        multiverseSpeed = map['multiverse_speed'],
        continent = map['continent'],
        idLeague = map['id_league'],
        idUser = map['id_user'],
        nameClub = map['name_club'],
        cashAbsolute = map['cash_absolute'],
        cashAvailable = map['cash_available'],
        numberFans = map['number_fans'],
        idCountry = map['id_country'],
        posSeason = List<int>.from(map['posSeason'] ?? []),
        posLastSeason = map['pos_last_season'],
        leaguePointsArray = List<double>.from(map['league_points_array'] ?? []),
        leaguePoints = map['league_points'].toDouble(),
        // leaguePoints = 3.9,
        lastResultsArray = List<int>.from(map['last_results_array'] ?? []),
        lastResult = map['last_result'],
        posLeague = map['pos_league'],
        seasonNumber = map['season_number'],
        idLeagueNextSeason = map['id_league_next_season'],
        posLeagueNextSeason = map['pos_league_next_season'];

  Widget getClubNameClickable(BuildContext context,
      {bool isRightClub = false}) {
    bool isMine =
        Provider.of<SessionProvider>(context).selectedClub.id_club == id
            ? true
            : false;
    Color color = isMine ? Colors.green : Colors.white;
    Text text = Text(
      nameClub,
      style: TextStyle(fontSize: 20, color: color),
      overflow: TextOverflow.fade, // or TextOverflow.ellipsis
      maxLines: 1,
      softWrap: false,
    );
    Icon icon = Icon(isMine ? icon_home : Icons.sports_soccer_outlined,
        color: color, size: 30);

    return Row(
      mainAxisAlignment:
          isRightClub ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              ClubPage.route(id),
            );
          },
          child: Row(
            children: [
              if (isRightClub) icon else text,
              SizedBox(width: 6),
              if (isRightClub) text else icon,
            ],
          ),
        ),
      ],
    );
  }
}
