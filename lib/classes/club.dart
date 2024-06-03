//ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/teamComp.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/player/class/player.dart';

class Club {
  TeamComp? teamcomp; //team composition
  List<Player> players = []; // List of players of the club

  Club({
    required this.id_club,
    required this.created_at,
    required this.id_league,
    required this.id_user,
    required this.is_default,
    required this.club_name,
    required this.username,
    required this.cash_absolute,
    required this.cash_available,
    required this.player_count,
    required this.number_fans,
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
  final String club_name;

  /// Username of the club manager
  final String? username;
  final int cash_absolute;
  final int cash_available;
  final int player_count;
  final int number_fans;

  /// Whether the club is owned by the current user
  final bool isMine;

  Club.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : //
        // id_club = map['id_club'],
        id_club = map['id'],
        created_at = DateTime.parse(map['created_at']),
        id_league = map['id_league'],
        id_user = map['id_user'],
        is_default = map['is_default'] == true,
        club_name = map['name_club'] ?? 'No Club Name',
        username = map['username'],
        cash_absolute = map['cash_absolute'],
        cash_available = map['cash_available'],
        player_count = map['player_count'] ?? 0,
        number_fans = map['number_fans'] ?? 0,
        isMine = myUserId == map['id_user'];

  Widget getClubNameClickable(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              ClubPage.route(id_club),
            );
          },
          child: Row(
            children: [
              Icon(Icons.home),
              SizedBox(
                width: 12,
              ),
              Text(
                club_name,
                style: TextStyle(fontSize: 24), // Increase the font size to 20
              ),
            ],
          ),
        ),
      ],
    );
  }
}
