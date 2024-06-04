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
  List<Map<String, dynamic>> players;

  factory TeamComp.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> players = [
      {'name': 'Goal Keeper', 'id': map['idgoalkeeper'], 'player': null},
      {
        'name': 'Left Back Winger',
        'id': map['idleftbackwinger'],
        'player': null
      },
      {
        'name': 'Left Central Back',
        'id': map['idleftcentralback'],
        'player': null
      },
      {'name': 'Central Back', 'id': map['idcentralback'], 'player': null},
      {
        'name': 'Right Central Back',
        'id': map['idrightcentralback'],
        'player': null
      },
      {
        'name': 'Right Back Winger',
        'id': map['idrightbackwinger'],
        'player': null
      },
      {'name': 'Left Winger', 'id': map['idleftwinger'], 'player': null},
      {
        'name': 'Left Midfielder',
        'id': map['idleftmidfielder'],
        'player': null
      },
      {
        'name': 'Central Midfielder',
        'id': map['idcentralmidfielder'],
        'player': null
      },
      {
        'name': 'Right Midfielder',
        'id': map['idrightmidfielder'],
        'player': null
      },
      {'name': 'Right Winger', 'id': map['idrightwinger'], 'player': null},
      {'name': 'Left Striker', 'id': map['idleftstriker'], 'player': null},
      {
        'name': 'Central Striker',
        'id': map['idcentralstriker'],
        'player': null
      },
      {'name': 'Right Striker', 'id': map['idrightstriker'], 'player': null},
      {'name': 'Sub 1', 'id': map['idsub1'], 'player': null},
      {'name': 'Sub 2', 'id': map['idsub2'], 'player': null},
      {'name': 'Sub 3', 'id': map['idsub3'], 'player': null},
      {'name': 'Sub 4', 'id': map['idsub4'], 'player': null},
      {'name': 'Sub 5', 'id': map['idsub5'], 'player': null},
      {'name': 'Sub 6', 'id': map['idsub6'], 'player': null},
    ];

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

  init_players(List<Player> list_players) {
    for (Map<String, dynamic> player
        in players.where((player) => player['id'] != null).toList()) {
      print('testPierre_init_players!!!');
      print(player);
      player['player'] = list_players.firstWhere((lp) => lp.id == player['id']);
      print('testPierre_init_players2!!!');
      if (player['player'] == null) {
        throw Exception(
            'No player found with id {${player['id']}} for the club with id {{$idClub}} for the game {{$idGame}}');
      }
      print(player);
    }
    print('fin de la boucle');
  }
}
