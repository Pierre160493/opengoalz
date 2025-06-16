import 'package:opengoalz/models/club/class/club_data.dart';

class ClubDataHistory {
  ClubDataHistory({
    required this.id,
    required this.createdAt,
    required this.numberSeason,
    required this.clubData,
    required this.numberWeak,
    required this.idClub,
  });

  final int id;
  final DateTime createdAt;
  final int numberSeason;
  final ClubData clubData;
  final int numberWeak;
  final int idClub;

  ClubDataHistory.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        createdAt = DateTime.parse(map['created_at']).toLocal(),
        numberSeason = map['number_season'] ??
            map['season_number'] ??
            (throw Exception(
                "Missing 'number_season'/'season_number' in map: $map")),
        clubData = ClubData.fromMap(map),
        numberWeak = map['number_weak'] ??
            map['week_number'] ??
            (throw Exception(
                "Missing 'number_weak'/'week_number' in map: $map")),
        idClub = map['id_club'] ??
            (throw Exception("Missing 'id_club' in map: $map"));
}
