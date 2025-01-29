import 'package:opengoalz/models/player/class/player.dart';

class PlayerPoaching {
  Player? player;

  final int id;
  final DateTime createdAt;
  final int idClub;
  final int idPlayer;
  final String? notes;
  final DateTime? dateDelete;
  final int investmentTarget;
  final List<int> investmentWeekly;
  final double affinity;
  final List<double> lisAffinity;
  final int? maxPrice;
  final bool toDelete;

  PlayerPoaching({
    required this.id,
    required this.createdAt,
    required this.idClub,
    required this.idPlayer,
    this.notes,
    this.dateDelete,
    required this.investmentTarget,
    required this.investmentWeekly,
    required this.affinity,
    required this.lisAffinity,
    this.maxPrice,
    required this.toDelete,
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
      investmentTarget: map['investment_target'],
      investmentWeekly: List<int>.from(map['investment_weekly']),
      affinity: (map['affinity'] as num).toDouble(),
      lisAffinity: (map['lis_affinity'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      maxPrice: map['max_price'],
      toDelete: map['to_delete'],
    );
  }
}
