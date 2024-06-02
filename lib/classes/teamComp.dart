import 'package:opengoalz/player/class/player.dart';

class TeamComp {
  TeamComp({
    required this.id,
    required this.idGame,
    required this.idClub,
    required this.goalKeeper,
    required this.leftBackWinger,
    required this.leftCentralBack,
    required this.centralBack,
    required this.rightCentralBack,
    required this.rightBackWinger,
    required this.leftWinger,
    required this.leftMidFielder,
    required this.centralMidFielder,
    required this.rightMidFielder,
    required this.rightWinger,
    required this.leftStriker,
    required this.centralStriker,
    required this.rightStriker,
    required this.sub1,
    required this.sub2,
    required this.sub3,
    required this.sub4,
    required this.sub5,
    required this.sub6,
  });

  final int id;
  final int idGame;
  final int idClub;
  final int? goalKeeper;
  final int? leftBackWinger;
  final int? leftCentralBack;
  final int? centralBack;
  final int? rightCentralBack;
  final int? rightBackWinger;
  final int? leftWinger;
  final int? leftMidFielder;
  final int? centralMidFielder;
  final int? rightMidFielder;
  final int? rightWinger;
  final int? leftStriker;
  final int? centralStriker;
  final int? rightStriker;
  final int? sub1;
  final int? sub2;
  final int? sub3;
  final int? sub4;
  final int? sub5;
  final int? sub6;

  factory TeamComp.fromMap(Map<String, dynamic> map, Map<int, Player> players) {
    return TeamComp(
      id: map['id'],
      idGame: map['id_game'],
      idClub: map['id_club'],
      goalKeeper: map['idgoalkeeper'],
      leftBackWinger: map['idleftbackwinger'],
      leftCentralBack: map['idleftcentralback'],
      centralBack: map['idcentralback'],
      rightCentralBack: map['idrightcentralback'],
      rightBackWinger: map['idrightbackwinger'],
      leftWinger: map['idleftwinger'],
      leftMidFielder: map['idleftmidfielder'],
      centralMidFielder: map['idcentralmidfielder'],
      rightMidFielder: map['idrightmidfielder'],
      rightWinger: map['idrightwinger'],
      leftStriker: map['idleftstriker'],
      centralStriker: map['idcentralstriker'],
      rightStriker: map['idrightstriker'],
      sub1: map['idsub1'],
      sub2: map['idsub2'],
      sub3: map['idsub3'],
      sub4: map['idsub4'],
      sub5: map['idsub5'],
      sub6: map['idsub6'],
    );
  }
}
