import 'package:opengoalz/models/club/club.dart';

class TransferBid {
  Club? club;

  TransferBid({
    required this.id,
    required this.createdAt,
    required this.amount,
    required this.idClub,
    required this.idPlayer,
    required this.nameClub,
  });

  final int id;
  final DateTime createdAt;
  final int amount;
  final int idClub;
  final int idPlayer;
  final String nameClub;

  TransferBid.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        createdAt = DateTime.parse(map['created_at']).toLocal(),
        amount = map['amount'],
        idClub = map['id_club'],
        idPlayer = map['id_player'],
        nameClub = map['name_club'];
}
