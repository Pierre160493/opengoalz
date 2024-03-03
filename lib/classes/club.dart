// ignore_for_file: non_constant_identifier_names

class Club {
  Club({
    required this.id,
    required this.created_at,
    required this.id_league,
    required this.id_user,
    required this.club_name,
    required this.username,
    required this.isMine,
  });

  /// ID of the club
  final int id;

  /// Date and time when the club was created
  final DateTime created_at;

  /// ID of the league where the club belongs
  final int? id_league;

  /// Date and time when the message was created
  final String? id_user;

  /// Name of the club
  final String? club_name;

  /// Username of the club manager
  final String? username;

  /// Whether the club is owned by the current user
  final bool isMine;

  Club.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id = map['id'],
        created_at = DateTime.parse(map['created_at']),
        id_league = map['id_league'],
        id_user = map['id_user'],
        club_name = map['club_name'],
        username = map['username'],
        isMine = myUserId == map['id_user'];
}
