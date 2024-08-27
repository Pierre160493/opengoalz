class Multiverse {
  final int speed;
  final int seasonNumber;
  final DateTime dateSeasonStart;
  final DateTime dateSeasonEnd;
  final int weekNumber;
  final int cashPrinted;

  Multiverse({
    required this.speed,
    required this.seasonNumber,
    required this.dateSeasonStart,
    required this.dateSeasonEnd,
    required this.weekNumber,
    required this.cashPrinted,
  });

  factory Multiverse.fromMap(Map<String, dynamic> map) {
    return Multiverse(
      speed: map['speed'],
      seasonNumber: map['season_number'],
      dateSeasonStart: DateTime.parse(map['date_season_start']),
      dateSeasonEnd: DateTime.parse(map['date_season_end']),
      weekNumber: map['week_number'],
      cashPrinted: map['cash_printed'],
    );
  }
}
