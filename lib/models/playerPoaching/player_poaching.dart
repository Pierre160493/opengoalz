import 'package:opengoalz/models/player/class/player.dart';

class PlayerPoaching {
  Player? player;

  final int id;
  final DateTime createdAt;
  final int idClub;
  final int idPlayer;
  final int promisedExpenses;
  final int promisedPrice;

  PlayerPoaching({
    required this.id,
    required this.createdAt,
    required this.idClub,
    required this.idPlayer,
    required this.promisedExpenses,
    required this.promisedPrice,
  });

  factory PlayerPoaching.fromMap(Map<String, dynamic> map) {
    return PlayerPoaching(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      idClub: map['id_club'],
      idPlayer: map['id_player'],
      promisedExpenses: map['promised_expenses'],
      promisedPrice: map['promised_price'],
    );
  }
}