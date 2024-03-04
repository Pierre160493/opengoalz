import 'package:flutter/material.dart';

class Ranking {
  Ranking({
    required this.idClub,
    required this.nameClub,
    required this.idUser,
    required this.nPoints,
    required this.nVictories,
    required this.nDraws,
    required this.nDefeats,
    required this.totalGoalAverage,
    required this.goalsScored,
    required this.goalsTaken,
    required this.idLeague,
  });

  final int idClub;
  final String nameClub;
  final String? idUser;
  final int nPoints;
  final int nVictories;
  final int nDraws;
  final int nDefeats;
  final int totalGoalAverage;
  final int goalsScored;
  final int goalsTaken;
  final int idLeague;

  Ranking.fromMap(Map<String, dynamic> map)
      : idClub = map['id_club'],
        nameClub = map['name_club'],
        idUser = map['id_user'],
        nPoints = map['n_points'],
        nVictories = map['n_victories'],
        nDraws = map['n_draws'],
        nDefeats = map['n_defeats'],
        totalGoalAverage = map['total_goal_average'],
        goalsScored = map['goals_scored'],
        goalsTaken = map['goals_taken'],
        idLeague = map['id_league'];
}
