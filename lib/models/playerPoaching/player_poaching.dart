import 'package:opengoalz/models/player/class/player.dart';

class PlayerPoaching {
  Player? player;

  final int id;
  final DateTime createdAt;
  final int idClub;
  final int idPlayer;
  final String? notes;
  final DateTime? dateDelete;
  final List<int> investmentWeekly;
  final List<int> affinity;
  final int investmentTarget;

  PlayerPoaching({
    required this.id,
    required this.createdAt,
    required this.idClub,
    required this.idPlayer,
    this.notes,
    this.dateDelete,
    required this.investmentWeekly,
    required this.affinity,
    required this.investmentTarget,
  });

  factory PlayerPoaching.fromMap(Map<String, dynamic> map) {
    return PlayerPoaching(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      idClub: map['id_club'],
      idPlayer: map['id_player'],
      notes: map['notes'],
      dateDelete: map['date_delete'] != null
          ? DateTime.parse(map['date_delete'])
          : null,
      investmentWeekly: List<int>.from(map['investment_weekly']),
      affinity: List<int>.from(map['affinity']),
      investmentTarget: map['investment_target'],
    );
  }
}
