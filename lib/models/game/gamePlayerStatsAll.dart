class GamePlayerStatsAll {
  final int id;
  final DateTime createdAt;
  final int idGame;
  final int idPlayer;
  final int? minute;
  final List<double> weights;
  final int position;
  final double sumWeights;
  final int period;
  final bool isLeftClubPlayer;

  GamePlayerStatsAll({
    required this.id,
    required this.createdAt,
    required this.idGame,
    required this.idPlayer,
    this.minute,
    required this.weights,
    required this.position,
    required this.sumWeights,
    required this.period,
    required this.isLeftClubPlayer,
  });

  GamePlayerStatsAll.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        createdAt = DateTime.parse(map['created_at']).toLocal(),
        idGame = map['id_game'],
        idPlayer = map['id_player'],
        minute = map['minute'],
        weights = List<double>.from(map['weights'].map((x) => x.toDouble())),
        position = map['position'],
        sumWeights = map['sum_weights'].toDouble(),
        period = map['period'],
        isLeftClubPlayer = map['is_left_club_player'];
}
