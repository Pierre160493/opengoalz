import 'package:opengoalz/classes/club/club.dart';

class GameUser {
  late Club selectedClub; // Selected club of the profile
  List<Club> clubs = []; // List of clubs belonging to the profile
  int? idDefaultClub; // ID of the default club

  GameUser({
    required this.id,
    required this.username,
    required this.createdAt,
    this.idDefaultClub,
  });

  /// User ID of the profile
  final String id;

  /// Username of the profile
  final String username;

  /// Date and time when the profile was created
  final DateTime createdAt;

  GameUser.fromMap(Map<String, dynamic> map)
      : id = map['uuid_user'],
        username = map['username'],
        createdAt = DateTime.parse(map['created_at']),
        idDefaultClub = map['id_default_club'];
}
