import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/player/class/player.dart';

class Country {
  List<Club> clubs = [];
  List<Player> players = [];
  String? selectedContinent = null;

  final int id;
  final String name;
  final String iso2;
  final String? iso3;
  final String? localName;
  final List<String?> continents;
  final bool isActive;
  final DateTime? activatedAt;

  Country({
    required this.id,
    required this.name,
    required this.iso2,
    this.iso3,
    this.localName,
    required this.continents,
    required this.isActive,
    this.activatedAt,
  });

  factory Country.fromMap(Map<String, dynamic> map) {
    List<String?> continents = [];
    if (map['continents'] != null) {
      continents = List<String?>.from(map['continents']).map((continent) {
        if ((continent ?? '').isEmpty || continent == 'Antarctica') {
          return 'Others';
        }
        return continent;
      }).toList();
    }

    return Country(
      id: map['id'],
      name: map['name'],
      iso2: map['iso2'],
      iso3: map['iso3'],
      localName: map['local_name'],
      continents: continents,
      isActive: map['is_active'],
      activatedAt: map['activated_at'] != null
          ? DateTime.parse(map['activated_at']).toLocal()
          : null,
    );
  }
}
