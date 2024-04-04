// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class Player {
  Player(
      {required this.id,
      required this.created_at,
      required this.id_club,
      required this.first_name,
      required this.last_name,
      required this.date_birth,
      required this.age,
      required this.club_name,
      required this.username,
      required this.id_user,

      /// Stats
      required this.keeper,
      required this.defense,
      required this.playmaking,
      required this.passes,
      required this.winger,
      required this.scoring,
      required this.freekick,
      required this.avg_stats,

      /// Infos
      required this.date_end_injury,
      required this.date_firing,
      required this.is_currently_playing,

      /// Transfers
      required this.date_sell,
      required this.date_last_transfer_bid,
      required this.amount_last_transfer_bid,
      required this.id_club_last_transfer_bid,
      required this.name_club_last_transfer_bid});

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
  final String? club_name;

  /// Username of the club manager
  final String? username;

  /// ID of the user
  final String? id_user;

  ////// Stats
  final double keeper;
  final double defense;
  final double playmaking;
  final double passes;
  final double winger;
  final double scoring;
  final double freekick;
  final double avg_stats;

  /// Player is injured
  final DateTime? date_end_injury;
  final DateTime? date_firing;
  final bool is_currently_playing;

  ///
  final DateTime? date_sell;
  final DateTime? date_last_transfer_bid;
  final int? amount_last_transfer_bid;
  final int? id_club_last_transfer_bid;
  final String? name_club_last_transfer_bid;

  Player.fromMap({
    required Map<String, dynamic> map,
    // required String myUserId,
  })  : id = map['id'],
        created_at = DateTime.parse(map['created_at']),
        id_club = map['id_club'],
        first_name = map['first_name'],
        last_name = map['last_name'],
        date_birth = DateTime.parse(map['date_birth']),
        age = (map['age'] as num).toDouble(),
        club_name = map['current_club_name'],
        username = map['username'],
        id_user = map['id_user'],
        keeper = (map['keeper'] as num).toDouble(),
        defense = (map['defense'] as num).toDouble(),
        playmaking = (map['playmaking'] as num).toDouble(),
        passes = (map['passes'] as num).toDouble(),
        winger = (map['winger'] as num).toDouble(),
        scoring = (map['scoring'] as num).toDouble(),
        freekick = (map['freekick'] as num).toDouble(),
        avg_stats = (map['avg_stats'] as num).toDouble(),
        date_end_injury = map['date_end_injury'] != null
            ? DateTime.parse(map['date_end_injury'])
            : null,
        date_firing = map['date_firing'] != null
            ? DateTime.parse(map['date_firing'])
            : null,
        is_currently_playing = map["is_currently_playing"],
        date_sell =
            map['date_sell'] != null ? DateTime.parse(map['date_sell']) : null,
        date_last_transfer_bid = map['date_last_transfer_bid'] != null
            ? DateTime.parse(map['date_last_transfer_bid'])
            : null,
        amount_last_transfer_bid = map['amount_last_transfer_bid'] != null
            ? map['amount_last_transfer_bid']
            : null,
        id_club_last_transfer_bid = map['id_club_last_transfer_bid'] != null
            ? map['id_club_last_transfer_bid']
            : null,
        name_club_last_transfer_bid = map['name_club_last_transfer_bid'] != null
            ? map['name_club_last_transfer_bid']
            : null;

  /// Returns the status of the player (on transfer list, being fired, injured, etc...)
  Widget getStatusRow() {
    DateTime currentDate = DateTime.now();
    return Row(
      children: [
        if (date_sell != null)
          Stack(
            children: [
              const Icon(
                Icons.monetization_on,
                color: Colors.green,
                size: 30,
              ),
              Positioned(
                top: -12,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    date_sell!
                        .difference(currentDate)
                        .inDays
                        .toString(), // Change the number as needed
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        if (date_firing != null)
          Stack(
            children: [
              const Icon(
                Icons.exit_to_app,
                color: Colors.red,
                size: 30,
              ),
              Positioned(
                top: -12,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    date_firing!
                        .difference(currentDate)
                        .inDays
                        .toString(), // Change the number as needed
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        if (date_end_injury != null)
          Stack(
            children: [
              const Icon(
                Icons.local_hospital,
                color: Colors.red,
                size: 30,
              ),
              Positioned(
                top: -12,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    date_end_injury!
                        .difference(currentDate)
                        .inDays
                        .toString(), // Change the number as needed
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        if (is_currently_playing)
          const Icon(
            Icons.directions_run_outlined,
            color: Colors.green,
            size: 30,
          ),
      ],
    );
  }

  Widget getCountryWidget() {
    return Row(
      children: [
        Icon(
          Icons.flag_circle_outlined,
          size: 24, // Adjust icon size as needed
          color: Colors.grey, // Adjust icon color as needed
        ),
        Text(
          ' FRANCE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget getAgeWidget() {
    return Row(
      children: [
        Icon(
          Icons.cake_outlined,
          size: 24, // Adjust icon size as needed
          color: Colors.grey, // Adjust icon color as needed
        ),
        Text(
          ' ${age.truncate()}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(' years, '),
        Text(
          ((age - age.truncate()) * 112).floor().toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(' days '),
      ],
    );
  }

  Widget getAvgStatsWidget() {
    return Row(
      children: [
        Icon(
          Icons.query_stats_outlined,
          size: 24, // Adjust icon size as needed
          color: Colors.grey, // Adjust icon color as needed
        ),
        Text(
          ' ${avg_stats.toStringAsFixed(1)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(' Average Stats')
      ],
    );
  }

  Widget getClubWidget() {
    return Row(
      children: [
        Icon(
          Icons.real_estate_agent_outlined,
          size: 24, // Adjust icon size as needed
          color: Colors.grey, // Adjust icon color as needed
        ),
        Text(
          ' ${club_name}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(' Club')
      ],
    );
  }

  Widget getUserNameWidget() {
    return Row(
      children: [
        Icon(
          Icons.android_outlined,
          size: 24, // Adjust icon size as needed
          color: Colors.grey, // Adjust icon color as needed
        ),
        Text(
          ' ${username}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget getInjuryWidget() {
    return Row(
      children: [
        Icon(Icons.personal_injury_outlined,
            size: 24, color: Colors.red), // Adjust icon size and color
        Text(
          ' ${date_end_injury!.difference(DateTime.now()).inDays.toString()}',
          style: const TextStyle(
            fontWeight: FontWeight.bold, // Remove bold font weight
            // color: Colors.red,
          ),
        ),
        Text(' days left for recovery')
      ],
    );
  }
}
