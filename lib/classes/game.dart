class Game {
  Game({
    required this.id,
    required this.dateStart,
    required this.idClubLeft,
    required this.nameClubLeft,
    required this.idClubRight,
    required this.nameClubRight,
    required this.idStadium,
    required this.isPlayed,
    required this.isCup,
    required this.goalsLeft,
    required this.goalsRight,
    required this.idUserClubLeft,
    required this.usernameClubLeft,
    required this.idUserClubRight,
    required this.usernameClubRight,
    // required this.isMine,
  });

  /// ID of the game
  final int id;

  /// Date and time when the game starts
  final DateTime dateStart;

  /// ID of the left club
  final int idClubLeft;

  /// Name of the left club
  final String nameClubLeft;

  /// ID of the right club
  final int idClubRight;

  /// Name of the right club
  final String nameClubRight;

  /// ID of the stadium
  final int? idStadium;

  /// Indicates whether the game is played
  final bool isPlayed;

  /// Indicates whether the game is a cup match
  final bool isCup;

  /// Number of goals scored by the left club
  final int goalsLeft;

  /// Number of goals scored by the right club
  final int goalsRight;

  /// ID of the user for the left club
  final String? idUserClubLeft;

  /// Username of the user for the left club
  final String? usernameClubLeft;

  /// ID of the user for the right club
  final String? idUserClubRight;

  /// Username of the user for the right club
  final String? usernameClubRight;

  Game.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id = map['id'],
        dateStart = DateTime.parse(map['date_start']),
        idClubLeft = map['id_club_left'],
        nameClubLeft = map['name_club_left'],
        idUserClubLeft = map['id_user_club_left'],
        usernameClubLeft = map['username_club_left'],
        goalsLeft = map['goals_left'],
        idClubRight = map['id_club_right'],
        nameClubRight = map['name_club_right'],
        idUserClubRight = map['id_user_club_right'],
        usernameClubRight = map['username_club_right'],
        goalsRight = map['goals_right'],
        idStadium = map['id_stadium'],
        isPlayed = map['is_played'] == 1,
        isCup = map['is_cup'] == 1;
  // isMine = myUserId == map['id_user'];
}
