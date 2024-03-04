// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

class Club {
  Club({
    required this.id_club,
    required this.created_at,
    required this.id_league,
    required this.id_user,
    required this.is_default,
    required this.club_name,
    required this.username,
    required this.isMine,
  });

  /// ID of the club
  final int id_club;

  /// Date and time when the club was created
  final DateTime created_at;

  /// ID of the league where the club belongs
  final int? id_league;

  /// Date and time when the message was created
  final String? id_user;
  final bool is_default;

  /// Name of the club
  final String? club_name;

  /// Username of the club manager
  final String? username;

  /// Whether the club is owned by the current user
  final bool isMine;

  Club.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id_club = map['id_club'],
        created_at = DateTime.parse(map['created_at']),
        id_league = map['id_league'],
        id_user = map['id_user'],
        is_default = map['is_default'] == true,
        club_name = map['club_name'],
        username = map['username'],
        isMine = myUserId == map['id_user'];
}
