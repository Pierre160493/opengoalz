import 'package:opengoalz/models/player/class/player.dart';

class PlayerWithPosition {
  final String name;
  final String type;
  final String notesSmallDefault;
  final String shirtNumberDefault;
  final String database;
  int? id;
  Player? player;

  PlayerWithPosition({
    required this.name,
    required this.type,
    required this.notesSmallDefault,
    required this.shirtNumberDefault,
    required this.database,
    required this.id,
    required this.player,
  });
}
