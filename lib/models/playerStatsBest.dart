import 'package:flutter/material.dart';
import 'package:opengoalz/models/game/gameWeights/gameWeights.dart';

class GamePlayerStatsBest {
  final int id;
  final DateTime createdAt;
  final int idGame;
  final int idPlayer;
  final GameWeights weights; // Use GameWeights class
  final int position;
  final double sumWeights;
  final int stars;
  final bool isLeftClubPlayer;

  GamePlayerStatsBest({
    required this.id,
    required this.createdAt,
    required this.idGame,
    required this.idPlayer,
    required this.weights,
    required this.position,
    required this.sumWeights,
    required this.stars,
    required this.isLeftClubPlayer,
  });

  factory GamePlayerStatsBest.fromMap(Map<String, dynamic> map) {
    return GamePlayerStatsBest(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      idGame: map['id_game'],
      idPlayer: map['id_player'],
      weights: GameWeights.fromList(map['weights']),
      position: map['position'],
      sumWeights: map['sum_weights'].toDouble(),
      stars: map['stars'],
      isLeftClubPlayer: map['is_left_club_player'],
    );
  }
}

Widget buildStarIcon(int stars, double iconSize) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Icon(
        Icons.star,
        size: iconSize,
        color: Colors.yellow,
      ),
      Positioned(
        top: 10,
        child: Text(
          stars.toString(),
          style: TextStyle(
            fontSize: iconSize / 3,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    ],
  );
}
