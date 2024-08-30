import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/players_page.dart';

class GameEvent {
  Player? player;
  Player? player2;
  Player? player3;
  String description = 'Unknown event';

  final int id;
  final DateTime createdAt;
  final int idGame;
  final String eventType;
  final int idEventType;
  final int? idPlayer;
  final int idClub;
  final int gameMinute;
  final DateTime? dateEvent;
  final int gamePeriod;
  final int? idPlayer2;
  final int? idPlayer3;

  GameEvent({
    required this.id,
    required this.createdAt,
    required this.idGame,
    required this.eventType,
    required this.idEventType,
    this.idPlayer,
    required this.idClub,
    required this.gameMinute,
    this.dateEvent,
    required this.gamePeriod,
    this.idPlayer2,
    this.idPlayer3,
  });

  factory GameEvent.fromMap(Map<String, dynamic> map) {
    return GameEvent(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      idGame: map['id_game'],
      eventType: map['event_type'],
      idEventType: map['id_event_type'],
      idPlayer: map['id_player'],
      idClub: map['id_club'],
      gameMinute: map['game_minute'],
      dateEvent:
          map['date_event'] != null ? DateTime.parse(map['date_event']) : null,
      gamePeriod: map['game_period'],
      idPlayer2: map['id_player2'],
      idPlayer3: map['id_player3'],
    );
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'created_at': createdAt.toIso8601String(),
  //     'id_game': idGame,
  //     'id_event_type': idEventType,
  //     'id_player': idPlayer,
  //     'id_club': idClub,
  //     'game_minute': gameMinute,
  //     'date_event': dateEvent?.toIso8601String(),
  //     'game_period': gamePeriod,
  //     'id_player_second': idPlayer2,
  //     'id_player_opponent': idPlayer3,
  //   };
  // }

  Widget getMinuteIcon() {
    return Text(
      '${gameMinute.toString()}\'',
      // '120+12\'',
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  String getMinute() {
    String minute = 'ERROR when trying to write the game minute';
    if (gamePeriod == 1) {
      if (gameMinute < 45) {
        minute = gameMinute.toString();
      } else {
        minute = '45+${gameMinute - 45}';
      }
    } else if (gamePeriod == 2) {
      if (gameMinute < 90) {
        minute = gameMinute.toString();
      } else {
        minute = '90+${gameMinute - 90}';
      }
    } else if (gamePeriod == 3) {
      if (gameMinute < 105) {
        minute = gameMinute.toString();
      } else {
        minute = '105+${gameMinute - 105}';
      }
    } else if (gamePeriod == 4) {
      if (gameMinute < 120) {
        minute = gameMinute.toString();
      } else {
        minute = '120+${gameMinute - 120}';
      }
    }
    return minute + '\'';
  }

  Widget getEventPresentation(BuildContext context) {
    String playerName = player == null
        ? 'Unknown player'
        : '${player!.firstName} ${player!.lastName.toUpperCase()}';

    Widget playerInkWell = InkWell(
      onTap: () {
        // Define your onTap action here, for example, navigate to the player's detail page
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayersPage(
                inputCriteria: {
                  'Players': [player!.id]
                },
              ),
            ));
      },
      child: Text(
        playerName,
        style: TextStyle(
          color: Colors.blue, // Change color to indicate it's clickable
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );

    switch (eventType.toUpperCase()) {
      case 'GOAL':
        return Row(
          children: [
            Icon(Icons.sports_soccer_rounded, color: Colors.green),
            playerInkWell,
          ],
        );
      case 'INJURY':
        return Row(
          children: [
            Icon(Icons.medical_services, color: Colors.red),
            playerInkWell,
          ],
        );

      case 'YELLOW CARD':
        return Row(
          children: [
            Icon(Icons.turned_in, color: Colors.yellow),
            playerInkWell,
          ],
        );
      case 'OPPORTUNITY':
        return Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.red),
            playerInkWell,
          ],
        );
      case 'GAME START': // Game start
        return Row(
          children: [
            Text(
              'Referee blows his whistle, let the game begin !',
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case 'HALF TIME': // Half time
        return Row(
          children: [
            Text(
              'Referee blows his whistle, first half is over !',
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case 'GAME END': // Game end
        return Row(
          children: [
            Text(
              'Referee blows his whistle, game is over !',
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case 'ORDER ERROR': // Order error
        return Row(
          children: [
            Text(
              'The manager got messed up, his order doesnt make sense and was scrapped',
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case 'SUBSTITUTION': // Substitution order
        return Row(
          children: [
            Icon(Icons.swap_horiz),
            playerInkWell,
          ],
        );
      default:
        return Text(
          'Unknown event type',
          overflow: TextOverflow.ellipsis,
        );
    }
  }

  Widget getEventDescription(BuildContext context) {
    return Row(
      children: [Text(description)],
    );
  }

  String getEventDescription2(BuildContext context) {
    return description
        .replaceAll(
            '{player1}',
            player == null
                ? '[Unknown player]'
                : '${player!.firstName} ${player!.lastName.toUpperCase()}')
        .replaceAll(
            '{player2}',
            player2 == null
                ? '[Unknown player]'
                : '${player2!.firstName} ${player2!.lastName.toUpperCase()}')
        .replaceAll(
            '{opponent}',
            player3 == null
                ? '[Unknown player]'
                : '${player3!.firstName} ${player3!.lastName.toUpperCase()}');
  }
}
