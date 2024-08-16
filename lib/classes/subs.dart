class GameSub {
  final int id;
  final DateTime createdAt;
  final int idTeamComp;
  final int idPlayerOut;
  final int idPlayerIn;
  final int minute;
  final int? condition;
  final int? minuteReal;
  final String? error;

  GameSub({
    required this.id,
    required this.createdAt,
    required this.idTeamComp,
    required this.idPlayerOut,
    required this.idPlayerIn,
    required this.minute,
    this.condition,
    this.minuteReal,
    this.error,
  });

  GameSub.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        createdAt = DateTime.parse(map['created_at']),
        idTeamComp = map['id_teamcomp'],
        idPlayerOut = map['id_player_out'],
        idPlayerIn = map['id_player_in'],
        minute = map['minute'],
        condition = map['condition'],
        minuteReal = map['minute_real'],
        error = map['error'];
}
