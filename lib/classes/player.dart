// ignore_for_file: non_constant_identifier_names

class Player {
  Player({
    required this.id,
    required this.created_at,
    required this.id_club,
    required this.first_name,
    required this.last_name,
    required this.date_birth,
    required this.age,
    required this.club_name,
    required this.username,
    required this.id_user,
  });

  /// ID of the club
  final int id;

  /// Date and time when the club was created
  final DateTime created_at;

  /// ID of the club
  final int id_club;

  /// First name of the player
  final String first_name;

  /// Last name of the player
  final String last_name;

  /// Date of birth of the player
  final DateTime date_birth;

  /// Age of the player
  final double age;

  /// Name of the club
  final String club_name;

  /// Username of the club manager
  final String username;

  /// ID of the user
  final String id_user;

  Player.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id = map['id'],
        created_at = DateTime.parse(map['created_at']),
        id_club = map['id_club'],
        first_name = map['first_name'],
        last_name = map['last_name'],
        date_birth = DateTime.parse(map['date_birth']),
        age = map['age'],
        club_name = map['club_name'],
        username = map['username'],
        id_user = map['id_user'];
}
