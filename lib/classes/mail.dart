class Mail {
  final int id;
  final DateTime createdAt;
  final int clubId;
  final String title;
  final String message;
  final String? userFromId;
  final bool isRead;
  final bool isFavorite;
  final DateTime? dateDelete;

  Mail({
    required this.id,
    required this.createdAt,
    required this.clubId,
    required this.title,
    required this.message,
    this.userFromId,
    required this.isRead,
    required this.isFavorite,
    this.dateDelete,
  });

  factory Mail.fromMap(Map<String, dynamic> map) {
    return Mail(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      clubId: map['id_club'],
      title: map['title'],
      message: map['message'],
      userFromId: map['id_user_from'],
      isRead: map['is_read'],
      isFavorite: map['is_favorite'],
      dateDelete: map['date_delete'] != null
          ? DateTime.parse(map['date_delete'])
          : null,
    );
  }
}
