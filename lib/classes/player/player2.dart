// // ignore_for_file: non_constant_identifier_names

// import 'package:flutter/material.dart';
// import 'package:opengoalz/classes/club.dart';
// import 'package:opengoalz/constants.dart';

// part 'player_widgets.dart';

// class Player {
//   Player({
//     required this.id,
//     required this.created_at,
//     required this.id_club,
//     required this.first_name,
//     required this.last_name,
//     required this.date_birth,
//     required this.id_country,
//     required this.keeper,
//     required this.defense,
//     required this.playmaking,
//     required this.passes,
//     required this.scoring,
//     required this.freekick,
//     required this.winger,
//     required this.date_end_injury,
//     required this.date_firing,
//     required this.date_sell,
//     // required this.special_stats,
//     required this.date_arrival,
//     // required this.stamina,
//     // required this.form,
//     // required this.endurance,
//   });

//   final int id;
//   final DateTime created_at;
//   final int? id_club;
//   final String first_name;
//   final String last_name;
//   final DateTime date_birth;
//   final int? id_country; //Shouldn't be nullable
//   final double keeper;
//   final double defense;
//   final double playmaking;
//   final double passes;
//   final double scoring;
//   final double freekick;
//   final double winger;
//   final DateTime? date_end_injury;
//   final DateTime? date_firing;
//   final DateTime? date_sell;
//   // final List<double>? special_stats;
//   final DateTime date_arrival;
//   // final double stamina;
//   // final double form;
//   // final double endurance;

//   Player.fromMap(Map<String, dynamic> map)
//       : id = map['id'],
//         created_at = DateTime.parse(map['created_at']),
//         id_club = map['id_club'],
//         first_name = map['first_name'],
//         last_name = map['last_name'],
//         date_birth = DateTime.parse(map['date_birth']),
//         id_country = map['id_country'],
//         keeper = (map['keeper'] as num).toDouble(),
//         defense = (map['defense'] as num).toDouble(),
//         playmaking = (map['playmaking'] as num).toDouble(),
//         passes = (map['passes'] as num).toDouble(),
//         scoring = (map['scoring'] as num).toDouble(),
//         freekick = (map['freekick'] as num).toDouble(),
//         winger = (map['winger'] as num).toDouble(),

//         // stamina = map['stamina'],
//         // form = map['form'],
//         // endurance = map['endurance'],

//         date_end_injury = map['date_end_injury'] != null
//             ? DateTime.parse(map['date_end_injury'])
//             : null,
//         date_firing = map['date_firing'] != null
//             ? DateTime.parse(map['date_firing'])
//             : null,
//         date_sell =
//             map['date_sell'] != null ? DateTime.parse(map['date_sell']) : null,
//         // special_stats = (map['special_stats'] as List<dynamic>?)
//         //     ?.map<double>((e) => e as double)
//         //     .toList(),
//         date_arrival = DateTime.parse(map['date_arrival']);

//   double get age {
//     return DateTime.now().difference(date_birth).inDays / 112.0;
//   }

//   double get stats_average {
//     return (keeper +
//             defense +
//             playmaking +
//             passes +
//             scoring +
//             freekick +
//             winger) /
//         7.0;
//   }
// }
