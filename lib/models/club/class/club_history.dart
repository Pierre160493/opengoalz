import 'package:opengoalz/models/club/class/club_data.dart';

class ClubHistory {
  ClubHistory({
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

  ClubHistory.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        createdAt = DateTime.parse(map['created_at']).toLocal(),
        numberSeason = map['number_season'],
        clubData = ClubData.fromMap(map),
        numberWeak = map['number_weak'],
        idClub = map['id_club'];
}
