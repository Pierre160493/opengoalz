import 'package:flutter/material.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:opengoalz/classes/player/players_page.dart';

class GameEvent {
  Player? player;
  Player? playerSecond;
  Player? playerOpponent;

  final int id;
  final DateTime createdAt;
  final int idGame;
  final int? idEventType;
  final int? idPlayer;
  final int idClub;
  final int? gameMinute;
  final DateTime? dateEvent;
  final int? gamePeriod;
  final int? idPlayerSecond;
  final int? idPlayerOpponent;

  GameEvent({
    required this.id,
    required this.createdAt,
    required this.idGame,
    this.idEventType,
    this.idPlayer,
    required this.idClub,
    this.gameMinute,
    this.dateEvent,
    this.gamePeriod,
    this.idPlayerSecond,
    this.idPlayerOpponent,
  });

  factory GameEvent.fromMap(Map<String, dynamic> map) {
    return GameEvent(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      idGame: map['id_game'],
      idEventType: map['id_event_type'],
      idPlayer: map['id_player'],
      idClub: map['id_club'],
      gameMinute: map['game_minute'],
      dateEvent:
          map['date_event'] != null ? DateTime.parse(map['date_event']) : null,
      gamePeriod: map['game_period'],
      idPlayerSecond: map['id_player_second'],
      idPlayerOpponent: map['id_player_opponent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'id_game': idGame,
      'id_event_type': idEventType,
      'id_player': idPlayer,
      'id_club': idClub,
      'game_minute': gameMinute,
      'date_event': dateEvent?.toIso8601String(),
      'game_period': gamePeriod,
      'id_player_second': idPlayerSecond,
      'id_player_opponent': idPlayerOpponent,
    };
  }

  Widget getDescription(BuildContext context) {
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
      ),
    );

    switch (idEventType) {
      case 1:
        return Row(
          children: [
            Icon(Icons.sports_soccer_rounded, color: Colors.green),
            Text(' Fantastic goal by: '),
            playerInkWell,
          ],
        );
      case 2:
        return Row(
          children: [
            Text('What an assist by '),
            playerInkWell,
          ],
        );
      case 3:
        return Row(
          children: [
            Text('Yellow card for '),
            playerInkWell,
          ],
        );
      case 4:
        return Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.red),
            Text('Close shot from '),
            playerInkWell,
          ],
        );
      default:
        return Text('Unknown event type');
    }
  }
}
