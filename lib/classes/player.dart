// ignore_for_file: non_constant_identifier_names

class Player {
  Player(
      {required this.id,
      required this.created_at,
      required this.id_club,
      required this.first_name,
      required this.last_name,
      required this.date_birth,
      required this.age,
      required this.club_name,
      required this.username,
      required this.id_user,

      /// Stats
      required this.keeper,
      required this.defense,
      required this.playmaking,
      required this.passes,
      required this.winger,
      required this.scoring,
      required this.freekick,
      required this.avg_stats,

      /// Infos
      required this.date_end_injury,
      required this.date_firing,

      /// Transfers
      required this.date_sell,
      required this.date_last_transfer_bid,
      required this.amount_last_transfer_bid,
      required this.id_club_last_transfer_bid,
      required this.name_club_last_transfer_bid});

  /// ID of the club
  final int id;

  /// Date and time when the club was created
  final DateTime created_at;

  /// ID of the club
  final int id_club;

  /// First name of the player
  final String first_name;

  /// Last name of the player
  final String last_name;

  /// Date of birth of the player
  final DateTime date_birth;

  /// Age of the player
  final double age;

  /// Name of the club
  final String? club_name;

  /// Username of the club manager
  final String? username;

  /// ID of the user
  final String? id_user;

  ////// Stats
  final double keeper;
  final double defense;
  final double playmaking;
  final double passes;
  final double winger;
  final double scoring;
  final double freekick;
  final double avg_stats;

  /// Player is injured
  final DateTime? date_end_injury;
  final DateTime? date_firing;

  ///
  final DateTime? date_sell;
  final DateTime? date_last_transfer_bid;
  final int? amount_last_transfer_bid;
  final int? id_club_last_transfer_bid;
  final String? name_club_last_transfer_bid;

  Player.fromMap({
    required Map<String, dynamic> map,
    // required String myUserId,
  })  : id = map['id'],
        created_at = DateTime.parse(map['created_at']),
        id_club = map['id_club'],
        first_name = map['first_name'],
        last_name = map['last_name'],
        date_birth = DateTime.parse(map['date_birth']),
        age = (map['age'] as num).toDouble(),
        club_name = map['club_name'],
        username = map['username'],
        id_user = map['id_user'],
        keeper = (map['keeper'] as num).toDouble(),
        defense = (map['defense'] as num).toDouble(),
        playmaking = (map['playmaking'] as num).toDouble(),
        passes = (map['passes'] as num).toDouble(),
        winger = (map['winger'] as num).toDouble(),
        scoring = (map['scoring'] as num).toDouble(),
        freekick = (map['freekick'] as num).toDouble(),
        avg_stats = (map['avg_stats'] as num).toDouble(),
        date_end_injury = map['date_end_injury'] != null
            ? DateTime.parse(map['date_end_injury'])
            : null,
        date_firing = map['date_firing'] != null
            ? DateTime.parse(map['date_firing'])
            : null,
        date_sell =
            map['date_sell'] != null ? DateTime.parse(map['date_sell']) : null,
        date_last_transfer_bid = map['date_last_transfer_bid'] != null
            ? DateTime.parse(map['date_last_transfer_bid'])
            : null,
        amount_last_transfer_bid = map['amount_last_transfer_bid'] != null
            ? map['amount_last_transfer_bid']
            : null,
        id_club_last_transfer_bid = map['id_club_last_transfer_bid'] != null
            ? map['id_club_last_transfer_bid']
            : null,
        name_club_last_transfer_bid = map['name_club_last_transfer_bid'] != null
            ? map['name_club_last_transfer_bid']
            : null;
}
