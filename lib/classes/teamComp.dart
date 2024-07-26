// import 'package:opengoalz/classes/player/class/player.dart';

// class TeamComp {
//   TeamComp({
//     required this.id,
//     // required this.idGame,
//     required this.idClub,
//     required this.seasonNumber,
//     required this.weekNumber,
//     required this.players,
//   });

//   final int id;
//   // final int idGame;
//   final int idClub;
//   final int seasonNumber;
//   final int weekNumber;
//   final List<Map<String, dynamic>> players;

//   static List<Map<String, dynamic>> defaultPlayers = [
//     {
//       'name': 'Goal Keeper',
//       'type': 'Keeper',
//       'database': 'idgoalkeeper',
//       'id': null,
//       'player': null,
//     },
//     {
//       'name': 'Left Back Winger',
//       'type': 'Defense',
//       'database': 'idleftbackwinger',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Left Central Back',
//       'type': 'Defense',
//       'database': 'idleftcentralback',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Central Back',
//       'type': 'Defense',
//       'database': 'idcentralback',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Right Central Back',
//       'type': 'Defense',
//       'database': 'idrightcentralback',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Right Back Winger',
//       'type': 'Defense',
//       'database': 'idrightbackwinger',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Left Winger',
//       'type': 'Midfield',
//       'database': 'idleftwinger',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Left Midfielder',
//       'type': 'Midfield',
//       'database': 'idleftmidfielder',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Central Midfielder',
//       'type': 'Midfield',
//       'database': 'idcentralmidfielder',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Right Midfielder',
//       'type': 'Midfield',
//       'database': 'idrightmidfielder',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Right Winger',
//       'type': 'Midfield',
//       'database': 'idrightwinger',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Left Striker',
//       'type': 'Attack',
//       'database': 'idleftstriker',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Central Striker',
//       'type': 'Attack',
//       'database': 'idcentralstriker',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Right Striker',
//       'type': 'Attack',
//       'database': 'idrightstriker',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Sub 1',
//       'type': 'Sub',
//       'database': 'idsub1',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Sub 2',
//       'type': 'Sub',
//       'database': 'idsub2',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Sub 3',
//       'type': 'Sub',
//       'database': 'idsub3',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Sub 4',
//       'type': 'Sub',
//       'database': 'idsub4',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Sub 5',
//       'type': 'Sub',
//       'database': 'idsub5',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Sub 6',
//       'type': 'Sub',
//       'database': 'idsub6',
//       'id': null,
//       'player': null
//     },
//     {
//       'name': 'Sub 7',
//       'type': 'Sub',
//       'database': 'idsub7',
//       'id': null,
//       'player': null
//     },
//   ];

//   factory TeamComp.fromMap(Map<String, dynamic> map) {
//     List<Map<String, dynamic>> players = TeamComp.defaultPlayers.map((player) {
//       return {...player, 'id': map[player['database']]};
//     }).toList();

//     return TeamComp(
//       id: map['id'],
//       // idGame: map['id_game'],
//       idClub: map['id_club'],
//       seasonNumber: map['season_number'],
//       weekNumber: map['week_number'],
//       players: players,
//     );
//   }

//   List<int?> toListOfInt() {
//     List<int?> ids = [];
//     for (Map<String, dynamic> player in players) {
//       ids.add(player['id']);
//     }
//     // print(ids);
//     return ids;
//   }

//   void initPlayers(List<Player?> list_players) {
//     for (Map<String, dynamic> player
//         in players.where((player) => player['id'] != null).toList()) {
//       player['player'] =
//           list_players.firstWhere((lp) => lp!.id == player['id']);
//       if (player['player'] == null) {
//         throw Exception(
//             'No player found with id {${player['id']}} for the club with id {{$idClub}} for the game {{}}');
//       }
//     }
//   }

//   Map<String, dynamic>? getPlayerMapByName(String name) {
//     return players.firstWhere(
//       (player) => player['name'] == name,
//       orElse: () => {},
//     );
//   }
// }
