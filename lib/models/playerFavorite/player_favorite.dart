import 'package:opengoalz/models/player/class/player.dart';

class PlayerFavorite {
  Player? player;

  final int id;
  final DateTime createdAt;
  final int idClub;
  final int idPlayer;
  final int? promisedExpenses;
  final String? notes;
  final DateTime? dateDelete;

  PlayerFavorite({
    required this.id,
    required this.createdAt,
    required this.idClub,
    required this.idPlayer,
    this.promisedExpenses,
    this.notes,
    this.dateDelete,
  });

  factory PlayerFavorite.fromMap(Map<String, dynamic> map) {
    return PlayerFavorite(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      idClub: map['id_club'],
      idPlayer: map['id_player'],
      promisedExpenses: map['promised_expenses'],
      notes: map['notes'],
      dateDelete: map['date_delete'] != null
          ? DateTime.parse(map['date_delete'])
          : null,
    );
  }
}
