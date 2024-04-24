// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class ClubView {
  ClubView({
    required this.id_club,
    required this.created_at,
    required this.id_league,
    required this.id_user,
    required this.is_default,
    required this.name_club,
    required this.username,
    required this.cash_absolute,
    required this.cash_available,
    required this.player_count,
    required this.number_fans,
    required this.last_results,
    required this.isMine,
  });

  /// ID of the club
  final int id_club;

  /// Date and time when the club was created
  final DateTime created_at;

  /// ID of the league where the club belongs
  final int id_league;

  /// Date and time when the message was created
  final String? id_user;
  final bool is_default;

  /// Name of the club
  final String? name_club;

  /// Username of the club manager
  final String? username;
  final int cash_absolute;
  final int cash_available;
  final int player_count;
  final int number_fans;

  /// Last results of the club
  final String last_results;

  /// Whether the club is owned by the current user
  final bool isMine;

  ClubView.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id_club = map['id_club'],
        created_at = DateTime.parse(map['created_at']),
        id_league = map['id_league'],
        id_user = map['id_user'],
        is_default = map['is_default'] == true,
        name_club = map['name_club'],
        username = map['username'],
        cash_absolute = map['cash_absolute'],
        cash_available = map['cash_available'],
        player_count = map['player_count'] ?? 0,
        number_fans = map['number_fans'] ?? 0,
        last_results = map['last_results'],
        isMine = myUserId == map['id_user'];

  Widget getLastResults() {
    List<Icon> icons = [];

    // Mapping each character in lastResults to an icon with the corresponding color
    for (int i = 0; i < last_results.length; i++) {
      IconData iconData;
      Color color;

      // Determining icon and color based on result character
      switch (last_results[i]) {
        case 'V':
          iconData = Icons.check_circle;
          color = Colors.green;
          break;
        case 'D':
          iconData = Icons.remove_circle;
          color = Colors.grey;
          break;
        case 'L':
          iconData = Icons.cancel;
          color = Colors.red;
          break;
        default:
          // If character is not recognized, skip it
          continue;
      }

      // Adding the icon to the list
      icons.add(
        Icon(
          iconData,
          size: 24,
          color: color,
        ),
      );
    }

    // Returning a Row widget containing all the icons
    return Row(
      children: icons,
    );
  }
}
