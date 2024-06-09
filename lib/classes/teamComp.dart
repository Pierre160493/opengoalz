import 'package:opengoalz/player/class/player.dart';

class TeamComp {
  TeamComp({
    required this.id,
    required this.idGame,
    required this.idClub,
    required this.players,
  });

  final int id;
  final int idGame;
  final int idClub;
  final List<Map<String, dynamic>> players;

  static final List<Map<String, dynamic>> defaultPlayers = [
    {
      'name': 'Goal Keeper',
      'database': 'idgoalkeeper',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Back Winger',
      'database': 'idleftbackwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Central Back',
      'database': 'idleftcentralback',
      'id': null,
      'player': null
    },
    {
      'name': 'Central Back',
      'database': 'idcentralback',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Central Back',
      'database': 'idrightcentralback',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Back Winger',
      'database': 'idrightbackwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Winger',
      'database': 'idleftwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Midfielder',
      'database': 'idleftmidfielder',
      'id': null,
      'player': null
    },
    {
      'name': 'Central Midfielder',
      'database': 'idcentralmidfielder',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Midfielder',
      'database': 'idrightmidfielder',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Winger',
      'database': 'idrightwinger',
      'id': null,
      'player': null
    },
    {
      'name': 'Left Striker',
      'database': 'idleftstriker',
      'id': null,
      'player': null
    },
    {
      'name': 'Central Striker',
      'database': 'idcentralstriker',
      'id': null,
      'player': null
    },
    {
      'name': 'Right Striker',
      'database': 'idrightstriker',
      'id': null,
      'player': null
    },
    {'name': 'Sub 1', 'database': 'idsub1', 'id': null, 'player': null},
    {'name': 'Sub 2', 'database': 'idsub2', 'id': null, 'player': null},
    {'name': 'Sub 3', 'database': 'idsub3', 'id': null, 'player': null},
    {'name': 'Sub 4', 'database': 'idsub4', 'id': null, 'player': null},
    {'name': 'Sub 5', 'database': 'idsub5', 'id': null, 'player': null},
    {'name': 'Sub 6', 'database': 'idsub6', 'id': null, 'player': null},
  ];

  factory TeamComp.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> players = TeamComp.defaultPlayers;

    for (Map<String, dynamic> player in players) {
      player['id'] = map[player['database']];
    }

    return TeamComp(
      id: map['id'],
      idGame: map['id_game'],
      idClub: map['id_club'],
      players: players,
    );
  }

  List<int?> to_list_int() {
    List<int?> ids = [];
    for (Map<String, dynamic> player in players) {
      ids.add(player['id']);
    }
    return ids;
  }

  void init_players(List<Player?> list_players) {
    for (Map<String, dynamic> player
        in players.where((player) => player['id'] != null).toList()) {
      player['player'] = list_players.firstWhere((lp) => lp!.id == player['id'],
          orElse: () => null as Player?);
      if (player['player'] == null) {
        throw Exception(
            'No player found with id {${player['id']}} for the club with id {{$idClub}} for the game {{$idGame}}');
      }
    }
  }

  Map<String, dynamic>? getPlayerMapByName(String name) {
    return players.firstWhere(
      (player) => player['name'] == name,
      orElse: () => {},
    );
  }
}
