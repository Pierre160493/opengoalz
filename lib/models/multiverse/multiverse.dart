import 'package:opengoalz/constants.dart';

class Multiverse {
  final int id;
  final String name;
  final int speed;
  final int seasonNumber;
  final DateTime dateSeasonStart;
  final DateTime dateHandling;
  final DateTime dateSeasonEnd;
  final int weekNumber;
  final int dayNumber;
  final int cashPrinted;
  final DateTime lastRun;
  final String? error;
  final bool isActive;

  Multiverse({
    required this.id,
    required this.name,
    required this.speed,
    required this.seasonNumber,
    required this.dateSeasonStart,
    required this.dateHandling,
    required this.dateSeasonEnd,
    required this.weekNumber,
    required this.dayNumber,
    required this.cashPrinted,
    required this.lastRun,
    required this.error,
    required this.isActive,
  });

  factory Multiverse.fromMap(Map<String, dynamic> map) {
    return Multiverse(
      id: map['id'],
      name: map['name'],
      speed: map['speed'],
      seasonNumber: map['season_number'],
      dateSeasonStart: DateTime.parse(map['date_season_start']).toLocal(),
      dateHandling: DateTime.parse(map['date_handling']).toLocal(),
      dateSeasonEnd: DateTime.parse(map['date_season_end']).toLocal(),
      weekNumber: map['week_number'],
      dayNumber: map['day_number'],
      cashPrinted: map['cash_printed'],
      lastRun: DateTime.parse(map['last_run']).toLocal(),
      error: map['error'],
      isActive: map['is_active'], // New property
    );
  }

  static Future<Multiverse?> fromId(int id) async {
    final stream = supabase
        .from('multiverses')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((maps) => maps.map((map) => Multiverse.fromMap(map)).first);

    try {
      final multiverse = await stream.first;
      return multiverse;
    } catch (e) {
      print('Error fetching multiverse: $e');
      return null;
    }
  }
}
