import 'package:opengoalz/player/class/player.dart';

class TeamComp {
  TeamComp({
    required this.id,
    required this.idGame,
    required this.idClub,
    this.goalKeeper,
    this.leftBackWinger,
    this.leftCentralBack,
    this.centralBack,
    this.rightCentralBack,
    this.rightBackWinger,
    this.leftWinger,
    this.leftMidFielder,
    this.centralMidFielder,
    this.rightMidFielder,
    this.rightWinger,
    this.leftStriker,
    this.centralStriker,
    this.rightStriker,
    this.sub1,
    this.sub2,
    this.sub3,
    this.sub4,
    this.sub5,
    this.sub6,
  });

  final int id;
  final int idGame;
  final int idClub;
  final Player? goalKeeper;
  final Player? leftBackWinger;
  final Player? leftCentralBack;
  final Player? centralBack;
  final Player? rightCentralBack;
  final Player? rightBackWinger;
  final Player? leftWinger;
  final Player? leftMidFielder;
  final Player? centralMidFielder;
  final Player? rightMidFielder;
  final Player? rightWinger;
  final Player? leftStriker;
  final Player? centralStriker;
  final Player? rightStriker;
  final Player? sub1;
  final Player? sub2;
  final Player? sub3;
  final Player? sub4;
  final Player? sub5;
  final Player? sub6;

  factory TeamComp.fromMap(Map<String, dynamic> map, Map<int, Player> players) {
    return TeamComp(
      id: map['id'],
      idGame: map['id_game'],
      idClub: map['id_club'],
      goalKeeper: players[map['idgoalkeeper']],
      leftBackWinger: players[map['idleftbackwinger']],
      leftCentralBack: players[map['idleftcentralback']],
      centralBack: players[map['idcentralback']],
      rightCentralBack: players[map['idrightcentralback']],
      rightBackWinger: players[map['idrightbackwinger']],
      leftWinger: players[map['idleftwinger']],
      leftMidFielder: players[map['idleftmidfielder']],
      centralMidFielder: players[map['idcentralmidfielder']],
      rightMidFielder: players[map['idrightmidfielder']],
      rightWinger: players[map['idrightwinger']],
      leftStriker: players[map['idleftstriker']],
      centralStriker: players[map['idcentralstriker']],
      rightStriker: players[map['idrightstriker']],
      sub1: players[map['idsub1']],
      sub2: players[map['idsub2']],
      sub3: players[map['idsub3']],
      sub4: players[map['idsub4']],
      sub5: players[map['idsub5']],
      sub6: players[map['idsub6']],
    );
  }
}
