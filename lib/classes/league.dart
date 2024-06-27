class League {
  League({
    required this.id,
    // required this.createdAt,
    required this.multiverseSpeed,
    required this.seasonNumber,
    // this.continent,
    required this.level,
    this.idUpperLeague,
    this.idPreviousLeague,
  });

  final int id;
  // final DateTime createdAt;
  final int multiverseSpeed;
  final int seasonNumber;
  // final String? continent;
  final int level;
  final int? idUpperLeague;
  final int? idPreviousLeague;

  League.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        // createdAt = DateTime.parse(map['created_at']),
        multiverseSpeed = map['multiverse_speed'],
        seasonNumber = map['season_number'],
        // continent = map['continent'],
        level = map['level'],
        idUpperLeague = map['id_upper_league'],
        idPreviousLeague = map['id_previous_league'];
}
