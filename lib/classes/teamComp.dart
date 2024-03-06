class TeamComp {
  TeamComp({
    required this.id,
    required this.createdAt,
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
  final DateTime createdAt;
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
      createdAt: DateTime.parse(map['created_at']),
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
}
