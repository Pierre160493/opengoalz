import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerWidgets.dart';
import 'package:opengoalz/models/player/player_card.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/subs.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/postgresql_requests.dart';

part 'teamComp_tab_teamcomp.dart';
part 'teamComp_tab_orders.dart';
part 'teamComp_player_card.dart';

class TeamComp {
  List<GameSub> subs = [];
  Player? selectedPlayerForSubstitution;

  TeamComp({
    required this.id,
    required this.idClub,
    required this.seasonNumber,
    required this.weekNumber,
    required this.players,
    required this.name,
    required this.description,
    required this.isPlayed,
    required this.errors,
  });

  final int id;
  final int idClub;
  final int seasonNumber;
  final int weekNumber;
  final String name;
  final String description;
  final bool isPlayed;
  final List<String>? errors;
  final List<Map<String, dynamic>> players;

  static List<Map<String, dynamic>> defaultPlayers = [
    {
      'name': 'Goal Keeper',
      'type': 'Keeper',
      'database': 'idgoalkeeper',
      'id': null,
      'player': null,
    },
    {
      'name': 'Left Back Winger',
      'type': 'Defense',
      'database': 'idleftbackwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Central Back',
      'type': 'Defense',
      'database': 'idleftcentralback',
      'id': null,
      'player': null
    },
    {
      'name': 'Central Back',
      'type': 'Defense',
      'database': 'idcentralback',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Central Back',
      'type': 'Defense',
      'database': 'idrightcentralback',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Back Winger',
      'type': 'Defense',
      'database': 'idrightbackwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Winger',
      'type': 'Midfield',
      'database': 'idleftwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Midfielder',
      'type': 'Midfield',
      'database': 'idleftmidfielder',
      'id': null,
      'player': null
    },
    {
      'name': 'Central Midfielder',
      'type': 'Midfield',
      'database': 'idcentralmidfielder',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Midfielder',
      'type': 'Midfield',
      'database': 'idrightmidfielder',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Winger',
      'type': 'Midfield',
      'database': 'idrightwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Striker',
      'type': 'Attack',
      'database': 'idleftstriker',
      'id': null,
      'player': null
    },
    {
      'name': 'Central Striker',
      'type': 'Attack',
      'database': 'idcentralstriker',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Striker',
      'type': 'Attack',
      'database': 'idrightstriker',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 1',
      'type': 'Sub',
      'database': 'idsub1',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 2',
      'type': 'Sub',
      'database': 'idsub2',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 3',
      'type': 'Sub',
      'database': 'idsub3',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 4',
      'type': 'Sub',
      'database': 'idsub4',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 5',
      'type': 'Sub',
      'database': 'idsub5',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 6',
      'type': 'Sub',
      'database': 'idsub6',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 7',
      'type': 'Sub',
      'database': 'idsub7',
      'id': null,
      'player': null
    },
  ];

  factory TeamComp.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> players = TeamComp.defaultPlayers.map((player) {
      return {...player, 'id': map[player['database']]};
    }).toList();

    return TeamComp(
      id: map['id'],
      // idGame: map['id_game'],
      idClub: map['id_club'],
      seasonNumber: map['season_number'],
      weekNumber: map['week_number'],
      name: map['name'],
      description: map['description'],
      isPlayed: map['is_played'],
      errors: map['error'] != null ? List<String>.from(map['error']) : null,
      players: players,
    );
  }

  List<int?> playersIdToListOfInt() {
    List<int?> ids = [];
    for (Map<String, dynamic> player in players) {
      ids.add(player['id']);
    }
    // print(ids);
    return ids;
  }

  void initPlayers(List<Player?> list_players) {
    for (Map<String, dynamic> player
        in players.where((player) => player['id'] != null).toList()) {
      player['player'] =
          list_players.firstWhere((lp) => lp!.id == player['id']);
      print(player['player']);
      if (player['player'] == null) {
        throw Exception(
            'No player found with id {${player['id']}} for the club with id {{$idClub}} for the game {{}}');
      }
    }
  }

  Map<String, dynamic>? getPlayerMapByName(String name) {
    return players.firstWhere(
      (player) => player['name'] == name,
      orElse: () => {},
    );
  }
}
