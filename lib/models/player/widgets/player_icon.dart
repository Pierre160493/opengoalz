import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/class/player.dart';

class PlayerIcon extends StatelessWidget {
  final Player player;
  final double size;
  final Color? color;

  const PlayerIcon({
    Key? key,
    required this.player,
    this.size = 24.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (player.id % 10) {
      case 0:
        icon = Icons.person;
        break;
      case 1:
        icon = Icons.face_5;
        break;
      case 2:
        icon = Icons.person_3;
        break;
      case 3:
        icon = Icons.person_4;
        break;
      case 4:
        icon = Icons.person_outline;
        break;
      case 5:
        icon = Icons.person_pin;
        break;
      case 6:
        icon = Icons.face_6;
        break;
      case 7:
        icon = Icons.person_pin_rounded;
        break;
      case 8:
        icon = Icons.person_2;
        break;
      case 9:
        icon = Icons.face;
        break;
      default:
        icon = Icons.error;
    }
    return Icon(icon, size: size, color: color);
  }
}
