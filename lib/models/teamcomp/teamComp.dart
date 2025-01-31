import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerWidgets.dart';
import 'package:opengoalz/models/player/playerCard_Main.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/subs.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

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
      'notes_small_default': 'GK',
      'shirt_number_default': '1',
      'database': 'idgoalkeeper',
      'id': null,
      'player': null,
    },
    {
      'name': 'Left Back Winger',
      'type': 'Defense',
      'notes_small_default': 'BW_L',
      'shirt_number_default': '2',
      'database': 'idleftbackwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Central Back',
      'type': 'Defense',
      'notes_small_default': 'CB_L',
      'shirt_number_default': '4',
      'database': 'idleftcentralback',
      'id': null,
      'player': null
    },
    {
      'name': 'Central Back',
      'type': 'Defense',
      'notes_small_default': 'CB_C',
      'shirt_number_default': '95',
      'database': 'idcentralback',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Central Back',
      'type': 'Defense',
      'notes_small_default': 'CB_R',
      'shirt_number_default': '5',
      'database': 'idrightcentralback',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Back Winger',
      'type': 'Defense',
      'notes_small_default': 'BW_R',
      'shirt_number_default': '3',
      'database': 'idrightbackwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Winger',
      'type': 'Midfield',
      'notes_small_default': 'WI_L',
      'shirt_number_default': '7',
      'database': 'idleftwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Midfielder',
      'type': 'Midfield',
      'notes_small_default': 'MD_L',
      'shirt_number_default': '6',
      'database': 'idleftmidfielder',
      'id': null,
      'player': null
    },
    {
      'name': 'Central Midfielder',
      'type': 'Midfield',
      'notes_small_default': 'MD_C',
      'shirt_number_default': '96',
      'database': 'idcentralmidfielder',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Midfielder',
      'type': 'Midfield',
      'notes_small_default': 'MD_R',
      'shirt_number_default': '10',
      'database': 'idrightmidfielder',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Winger',
      'type': 'Midfield',
      'notes_small_default': 'WI_R',
      'shirt_number_default': '8',
      'database': 'idrightwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Striker',
      'type': 'Attack',
      'notes_small_default': 'ST_L',
      'shirt_number_default': '9',
      'database': 'idleftstriker',
      'id': null,
      'player': null
    },
    {
      'name': 'Central Striker',
      'type': 'Attack',
      'notes_small_default': 'ST_C',
      'shirt_number_default': '99',
      'database': 'idcentralstriker',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Striker',
      'type': 'Attack',
      'notes_small_default': 'ST_R',
      'shirt_number_default': '11',
      'database': 'idrightstriker',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 1',
      'type': 'Sub',
      'notes_small_default': 'Sub1',
      'shirt_number_default': '12',
      'database': 'idsub1',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 2',
      'type': 'Sub',
      'notes_small_default': 'Sub2',
      'shirt_number_default': '13',
      'database': 'idsub2',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 3',
      'type': 'Sub',
      'notes_small_default': 'Sub3',
      'shirt_number_default': '14',
      'database': 'idsub3',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 4',
      'type': 'Sub',
      'notes_small_default': 'Sub4',
      'shirt_number_default': '15',
      'database': 'idsub4',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 5',
      'type': 'Sub',
      'notes_small_default': 'Sub5',
      'shirt_number_default': '16',
      'database': 'idsub5',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 6',
      'type': 'Sub',
      'notes_small_default': 'Sub6',
      'shirt_number_default': '17',
      'database': 'idsub6',
      'id': null,
      'player': null
    },
    {
      'name': 'Sub 7',
      'type': 'Sub',
      'notes_small_default': 'Sub7',
      'shirt_number_default': '18',
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

  Future<void> updatePlayerNotesToDefaultBasedOnPos(BuildContext context,
      {bool updateSmallNotes = false, bool updateShirtNumber = false}) async {
    if (!updateSmallNotes && !updateShirtNumber) {
      return;
    }

    String message = 'Are you sure you want to update ';
    String details = '';
    if (updateSmallNotes && updateShirtNumber) {
      details = 'the small notes and shirt numbers';
    } else if (updateSmallNotes) {
      details = 'the small notes';
    } else if (updateShirtNumber) {
      details = 'the shirt numbers';
    }
    message += '$details for players based on their position?';

    bool confirm = await context.showConfirmationDialog(message);

    if (!confirm) return;

    for (Map<String, dynamic> player in players) {
      if (player['id'] != null) {
        Map<String, dynamic> data = {};
        if (updateSmallNotes) {
          data['notes_small'] = player['notes_small_default'];
        }
        if (updateShirtNumber) {
          data['shirt_number'] = player['shirt_number_default'];
        }
        bool isOK = await operationInDB(
          context,
          'UPDATE',
          'players',
          data: data,
          matchCriteria: {'id': player['id']},
        );
        if (!isOK) {
          context.showSnackBar(
            'Couldn\'t update the notes for ${player['name']}',
            icon: Icon(iconSuccessfulOperation, color: Colors.green),
          );
        }
      }
    }
    context.showSnackBar(
      'Successfully updated $details for all players based on their position',
      icon: Icon(iconSuccessfulOperation, color: Colors.green),
    );
    Navigator.pop(context);
  }
}
