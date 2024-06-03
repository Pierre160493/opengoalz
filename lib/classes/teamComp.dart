import 'package:opengoalz/player/class/player.dart';

class TeamComp {
  Player? goalKeeper; //Goalkeeper
  Player? leftBackWinger; //Left back winger
  Player? leftCentralBack; //Left central back
  Player? centralBack; //Central back
  Player? rightCentralBack; //Right central back
  Player? rightBackWinger; //Right back winger
  Player? leftWinger; //Left winger
  Player? leftMidFielder; //Left midfielder
  Player? centralMidFielder; //Central midfielder
  Player? rightMidFielder; //Right midfielder
  Player? rightWinger; //Right winger
  Player? leftStriker; //Left striker
  Player? centralStriker; //Central striker
  Player? rightStriker; //Right striker
  Player? sub1; //Substitute 1
  Player? sub2; //Substitute 2
  Player? sub3; //Substitute 3
  Player? sub4; //Substitute 4
  Player? sub5; //Substitute 5
  Player? sub6; //Substitute 6

  TeamComp({
    required this.id,
    required this.idGame,
    required this.idClub,
    required this.idGoalKeeper,
    required this.idLeftBackWinger,
    required this.idLeftCentralBack,
    required this.idCentralBack,
    required this.idRightCentralBack,
    required this.idRightBackWinger,
    required this.idLeftWinger,
    required this.idLeftMidFielder,
    required this.idCentralMidFielder,
    required this.idRightMidFielder,
    required this.idRightWinger,
    required this.idLeftStriker,
    required this.idCentralStriker,
    required this.idRightStriker,
    required this.idSub1,
    required this.idSub2,
    required this.idSub3,
    required this.idSub4,
    required this.idSub5,
    required this.idSub6,
  });

  final int id;
  final int idGame;
  final int idClub;
  final int? idGoalKeeper;
  final int? idLeftBackWinger;
  final int? idLeftCentralBack;
  final int? idCentralBack;
  final int? idRightCentralBack;
  final int? idRightBackWinger;
  final int? idLeftWinger;
  final int? idLeftMidFielder;
  final int? idCentralMidFielder;
  final int? idRightMidFielder;
  final int? idRightWinger;
  final int? idLeftStriker;
  final int? idCentralStriker;
  final int? idRightStriker;
  final int? idSub1;
  final int? idSub2;
  final int? idSub3;
  final int? idSub4;
  final int? idSub5;
  final int? idSub6;

  factory TeamComp.fromMap(Map<String, dynamic> map) {
    return TeamComp(
      id: map['id'],
      idGame: map['id_game'],
      idClub: map['id_club'],
      idGoalKeeper: map['idgoalkeeper'],
      idLeftBackWinger: map['idleftbackwinger'],
      idLeftCentralBack: map['idleftcentralback'],
      idCentralBack: map['idcentralback'],
      idRightCentralBack: map['idrightcentralback'],
      idRightBackWinger: map['idrightbackwinger'],
      idLeftWinger: map['idleftwinger'],
      idLeftMidFielder: map['idleftmidfielder'],
      idCentralMidFielder: map['idcentralmidfielder'],
      idRightMidFielder: map['idrightmidfielder'],
      idRightWinger: map['idrightwinger'],
      idLeftStriker: map['idleftstriker'],
      idCentralStriker: map['idcentralstriker'],
      idRightStriker: map['idrightstriker'],
      idSub1: map['idsub1'],
      idSub2: map['idsub2'],
      idSub3: map['idsub3'],
      idSub4: map['idsub4'],
      idSub5: map['idsub5'],
      idSub6: map['idsub6'],
    );
  }

  List<int?> get to_list_int {
    return [
      idGoalKeeper,
      idLeftBackWinger,
      idLeftCentralBack,
      idCentralBack,
      idRightCentralBack,
      idRightBackWinger,
      idLeftWinger,
      idLeftMidFielder,
      idCentralMidFielder,
      idRightMidFielder,
      idRightWinger,
      idLeftStriker,
      idCentralStriker,
      idRightStriker,
      idSub1,
      idSub2,
      idSub3,
      idSub4,
      idSub5,
      idSub6,
    ];
  }

  init_players(List<Player> players) {
    goalKeeper = players.firstWhere((player) => player.id == idGoalKeeper);
    leftBackWinger =
        players.firstWhere((player) => player.id == idLeftBackWinger);
    leftCentralBack =
        players.firstWhere((player) => player.id == idLeftCentralBack);
    centralBack = players.firstWhere((player) => player.id == idCentralBack);
    rightCentralBack =
        players.firstWhere((player) => player.id == idRightCentralBack);
    rightBackWinger =
        players.firstWhere((player) => player.id == idRightBackWinger);
    leftWinger = players.firstWhere((player) => player.id == idLeftWinger);
    leftMidFielder =
        players.firstWhere((player) => player.id == idLeftMidFielder);
    centralMidFielder =
        players.firstWhere((player) => player.id == idCentralMidFielder);
    rightMidFielder =
        players.firstWhere((player) => player.id == idRightMidFielder);
    rightWinger = players.firstWhere((player) => player.id == idRightWinger);
    leftStriker = players.firstWhere((player) => player.id == idLeftStriker);
    centralStriker =
        players.firstWhere((player) => player.id == idCentralStriker);
    rightStriker = players.firstWhere((player) => player.id == idRightStriker);
    sub1 = players.firstWhere((player) => player.id == idSub1);
    sub2 = players.firstWhere((player) => player.id == idSub2);
    sub3 = players.firstWhere((player) => player.id == idSub3);
    sub4 = players.firstWhere((player) => player.id == idSub4);
    sub5 = players.firstWhere((player) => player.id == idSub5);
    sub6 = players.firstWhere((player) => player.id == idSub6);
  }
}
