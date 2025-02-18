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
import 'package:opengoalz/models/playerPosition.dart';

part 'teamComp_tab_orders.dart';
part 'teamComp_player_card.dart';

class TeamComp {
  List<GameSub> subs = [];
  Player? selectedPlayerForSubstitution;

  TeamComp({
    required this.id,
    required this.idGame,
    required this.idClub,
    required this.seasonNumber,
    required this.weekNumber,
    required this.playersWithPosition,
    required this.name,
    required this.description,
    required this.isPlayed,
    required this.errors,
  });

  final int id;
  final int idGame;
  final int idClub;
  final int seasonNumber;
  final int weekNumber;
  final String name;
  final String description;
  final bool isPlayed;
  final List<String>? errors;
  final List<PlayerWithPosition> playersWithPosition;

  static List<PlayerWithPosition> defaultPlayers = [
    PlayerWithPosition(
      name: 'Goal Keeper',
      type: 'Keeper',
      notesSmallDefault: 'GK',
      shirtNumberDefault: '1',
      database: 'idgoalkeeper',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Left Back Winger',
      type: 'Defense',
      notesSmallDefault: 'BW_L',
      shirtNumberDefault: '2',
      database: 'idleftbackwinger',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Left Central Back',
      type: 'Defense',
      notesSmallDefault: 'CB_L',
      shirtNumberDefault: '4',
      database: 'idleftcentralback',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Central Back',
      type: 'Defense',
      notesSmallDefault: 'CB_C',
      shirtNumberDefault: '95',
      database: 'idcentralback',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Right Central Back',
      type: 'Defense',
      notesSmallDefault: 'CB_R',
      shirtNumberDefault: '5',
      database: 'idrightcentralback',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Right Back Winger',
      type: 'Defense',
      notesSmallDefault: 'BW_R',
      shirtNumberDefault: '3',
      database: 'idrightbackwinger',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Left Winger',
      type: 'Midfield',
      notesSmallDefault: 'WI_L',
      shirtNumberDefault: '7',
      database: 'idleftwinger',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Left Midfielder',
      type: 'Midfield',
      notesSmallDefault: 'MD_L',
      shirtNumberDefault: '6',
      database: 'idleftmidfielder',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Central Midfielder',
      type: 'Midfield',
      notesSmallDefault: 'MD_C',
      shirtNumberDefault: '96',
      database: 'idcentralmidfielder',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Right Midfielder',
      type: 'Midfield',
      notesSmallDefault: 'MD_R',
      shirtNumberDefault: '10',
      database: 'idrightmidfielder',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Right Winger',
      type: 'Midfield',
      notesSmallDefault: 'WI_R',
      shirtNumberDefault: '8',
      database: 'idrightwinger',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Left Striker',
      type: 'Attack',
      notesSmallDefault: 'ST_L',
      shirtNumberDefault: '9',
      database: 'idleftstriker',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Central Striker',
      type: 'Attack',
      notesSmallDefault: 'ST_C',
      shirtNumberDefault: '99',
      database: 'idcentralstriker',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Right Striker',
      type: 'Attack',
      notesSmallDefault: 'ST_R',
      shirtNumberDefault: '11',
      database: 'idrightstriker',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Sub 1',
      type: 'Sub',
      notesSmallDefault: 'Sub1',
      shirtNumberDefault: '12',
      database: 'idsub1',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Sub 2',
      type: 'Sub',
      notesSmallDefault: 'Sub2',
      shirtNumberDefault: '13',
      database: 'idsub2',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Sub 3',
      type: 'Sub',
      notesSmallDefault: 'Sub3',
      shirtNumberDefault: '14',
      database: 'idsub3',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Sub 4',
      type: 'Sub',
      notesSmallDefault: 'Sub4',
      shirtNumberDefault: '15',
      database: 'idsub4',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Sub 5',
      type: 'Sub',
      notesSmallDefault: 'Sub5',
      shirtNumberDefault: '16',
      database: 'idsub5',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Sub 6',
      type: 'Sub',
      notesSmallDefault: 'Sub6',
      shirtNumberDefault: '17',
      database: 'idsub6',
      id: null,
      player: null,
    ),
    PlayerWithPosition(
      name: 'Sub 7',
      type: 'Sub',
      notesSmallDefault: 'Sub7',
      shirtNumberDefault: '18',
      database: 'idsub7',
      id: null,
      player: null,
    ),
  ];

  factory TeamComp.fromMap(Map<String, dynamic> map) {
    List<PlayerWithPosition> playersWithPosition =
        TeamComp.defaultPlayers.map((PlayerWithPosition playerWithPosition) {
      return PlayerWithPosition(
        name: playerWithPosition.name,
        type: playerWithPosition.type,
        notesSmallDefault: playerWithPosition.notesSmallDefault,
        shirtNumberDefault: playerWithPosition.shirtNumberDefault,
        database: playerWithPosition.database,
        id: map[playerWithPosition.database],
        player: null,
      );
    }).toList();

    return TeamComp(
      id: map['id'],
      idGame: map['id_game'],
      idClub: map['id_club'],
      seasonNumber: map['season_number'],
      weekNumber: map['week_number'],
      name: map['name'],
      description: map['description'],
      isPlayed: map['is_played'],
      errors: map['error'] != null ? List<String>.from(map['error']) : null,
      playersWithPosition: playersWithPosition,
    );
  }

  List<int?> playersIdToListOfInt() {
    return playersWithPosition.map((player) => player.id).toList();
  }

  void initPlayers(List<Player?> list_players) {
    for (PlayerWithPosition playerWithPosition
        in playersWithPosition.where((player) => player.id != null).toList()) {
      playerWithPosition.player =
          list_players.firstWhere((lp) => lp!.id == playerWithPosition.id);
      if (playerWithPosition.player == null) {
        throw Exception(
            'No player found with id {${playerWithPosition.id}} for the club with id {{$idClub}} for the game {{}}');
      }
    }
  }

  PlayerWithPosition getPlayerMapByName(String name) {
    return playersWithPosition.firstWhere(
      (PlayerWithPosition playerWithPosition) =>
          playerWithPosition.name == name,
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

    for (PlayerWithPosition playerWithPosition in playersWithPosition) {
      if (playerWithPosition.id != null) {
        Map<String, dynamic> data = {};
        if (updateSmallNotes) {
          data['notes_small'] = playerWithPosition.notesSmallDefault;
        }
        if (updateShirtNumber) {
          data['shirt_number'] = playerWithPosition.shirtNumberDefault;
        }
        bool isOK = await operationInDB(
          context,
          'UPDATE',
          'players',
          data: data,
          matchCriteria: {'id': playerWithPosition.id!},
        );
        if (!isOK) {
          context.showSnackBar(
            'Couldn\'t update the notes for ${playerWithPosition.name}',
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
