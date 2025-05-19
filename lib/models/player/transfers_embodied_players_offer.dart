class TransfersEmbodiedPlayersOffer {
  final int id;
  final DateTime createdAt;
  final int idPlayer;
  final int idClub;
  final int expensesOffered;
  final DateTime? dateLimit;
  final int numberSeason;
  final String? commentForPlayer;
  final String? commentForClub;
  final bool? isAccepted;
  final DateTime? dateDelete;

  TransfersEmbodiedPlayersOffer({
    required this.id,
    required this.createdAt,
    required this.idPlayer,
    required this.idClub,
    required this.expensesOffered,
    this.dateLimit,
    required this.numberSeason,
    this.commentForPlayer,
    this.commentForClub,
    this.isAccepted,
    this.dateDelete,
  });

  factory TransfersEmbodiedPlayersOffer.fromMap(Map<String, dynamic> map) {
    return TransfersEmbodiedPlayersOffer(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      idPlayer: map['id_player'],
      idClub: map['id_club'],
      expensesOffered: map['expenses_offered'],
      dateLimit: map['date_limit'] != null
          ? DateTime.parse(map['date_limit']).toLocal()
          : null,
      numberSeason: map['number_season'],
      commentForPlayer: map['comment_for_player'],
      commentForClub: map['comment_for_club'],
      isAccepted: map['is_accepted'],
      dateDelete: map['date_delete'] != null
          ? DateTime.parse(map['date_delete']).toLocal()
          : null,
    );
  }
}
