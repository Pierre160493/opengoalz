import 'package:opengoalz/models/player/class/player.dart';

class PlayerFavorite {
  Player? player;

  final int id;
  final DateTime createdAt;
  final int idClub;
  final int idPlayer;
  final int? promisedExpenses;

  PlayerFavorite({
    required this.id,
    required this.createdAt,
    required this.idClub,
    required this.idPlayer,
    this.promisedExpenses,
  });

  factory PlayerFavorite.fromMap(Map<String, dynamic> map) {
    return PlayerFavorite(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      idClub: map['id_club'],
      idPlayer: map['id_player'],
      promisedExpenses: map['promised_expenses'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'id_club': idClub,
      'id_players': idPlayer,
      'promised_expenses': promisedExpenses,
    };
  }
}
