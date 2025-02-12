class Mail {
  final int id;
  final DateTime createdAt;
  final int idClubTo;
  final String? usernameTo;
  final String title;
  final String? message;
  final String? userNameFrom;
  final String? senderRole;
  bool isRead;
  bool isFavorite;
  DateTime? dateDelete;
  bool isGameResult;
  bool isTransferInfo;
  bool isSeasonInfo;
  bool isClubInfo;

  Mail({
    required this.id,
    required this.createdAt,
    required this.idClubTo,
    required this.usernameTo,
    required this.title,
    required this.message,
    this.userNameFrom,
    this.senderRole,
    required this.isRead,
    required this.isFavorite,
    this.dateDelete,
    required this.isGameResult,
    required this.isTransferInfo,
    required this.isSeasonInfo,
    required this.isClubInfo,
  });

  factory Mail.fromMap(Map<String, dynamic> map) {
    return Mail(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      idClubTo: map['id_club_to'],
      usernameTo: map['username_to'],
      title: map['title'],
      message: map['message'],
      userNameFrom: map['username_from'],
      senderRole: map['sender_role'],
      isRead: map['is_read'],
      isFavorite: map['is_favorite'],
      dateDelete: map['date_delete'] != null
          ? DateTime.parse(map['date_delete']).toLocal()
          : null,
      isGameResult: map['is_game_result'],
      isTransferInfo: map['is_transfer_info'],
      isSeasonInfo: map['is_season_info'],
      isClubInfo: map['is_club_info'],
    );
  }
}
