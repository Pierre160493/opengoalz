import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/player_name_tooltip.dart';
import 'package:opengoalz/models/subs.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/models/playerPosition.dart';

part 'teamComp_tab_orders.dart';

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
  final int? idGame;
  final int idClub;
  final int seasonNumber;
  final int weekNumber;
  final String name;
  final String description;
  final bool isPlayed;
  final List<String>? errors;
  final List<PlayerWithPosition> playersWithPosition;

  static List<PlayerWithPosition> get defaultPlayers =>
      PlayerWithPosition.defaultPlayers;

  factory TeamComp.fromMap(Map<String, dynamic> map) {
    List<PlayerWithPosition> playersWithPosition = PlayerWithPosition
        .defaultPlayers
        .map((PlayerWithPosition playerWithPosition) {
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
