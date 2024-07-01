class League {
  League({
    required this.id,
    // required this.createdAt,
    required this.multiverseSpeed,
    required this.seasonNumber,
    required this.continent,
    required this.level,
    required this.number,
    this.idUpperLeague,
    this.idPreviousSeason,
  });

  final int id;
  // final DateTime createdAt;
  final int multiverseSpeed;
  final int seasonNumber;
  final String continent;
  final int level;
  final int number;
  final int? idUpperLeague;
  final int? idPreviousSeason;

  League.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        // createdAt = DateTime.parse(map['created_at']),
        multiverseSpeed = map['multiverse_speed'],
        seasonNumber = map['season_number'],
        continent = map['continent'],
        level = map['level'],
        number = map['number'],
        idUpperLeague = map['id_upper_league'],
        idPreviousSeason = map['id_previous_season'];
}
