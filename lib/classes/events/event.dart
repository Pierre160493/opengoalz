import 'package:flutter/material.dart';
import 'package:opengoalz/player/class/player.dart';
import 'package:opengoalz/player/players_page.dart';

class GameEvent {
  Player? player;

  final int id;
  final DateTime createdAt;
  final int id_game;
  final int? idEventType;
  final int? id_player;
  final int id_club;
  final int gameMinute;
  final DateTime dateEvent;
  final int gamePeriod;

  GameEvent({
    required this.id,
    required this.createdAt,
    required this.id_game,
    this.idEventType,
    required this.id_player,
    required this.id_club,
    required this.gameMinute,
    required this.dateEvent,
    required this.gamePeriod,
  });

  // Factory constructor to create a GameEvent instance from a map
  factory GameEvent.fromMap(Map<String, dynamic> map) {
    return GameEvent(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      id_game: map['id_game'],
      idEventType: map['id_event_type'],
      id_player: map['id_player'],
      id_club: map['id_club'],
      gameMinute: map['game_minute'],
      dateEvent: DateTime.parse(map['date_event']),
      gamePeriod: map['game_period'],
    );
  }

  // Method to convert a GameEvent instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'id_game': id_game,
      'id_event_type': idEventType,
      'id_player': id_player,
      'id_club': id_club,
      'game_minute': gameMinute,
      'date_event': dateEvent.toIso8601String(),
      'game_period': gamePeriod,
    };
  }

  Widget getDescription(BuildContext context) {
    String playerName = player == null
        ? 'Unknown player'
        : '${player!.first_name} ${player!.last_name.toUpperCase()}';

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
