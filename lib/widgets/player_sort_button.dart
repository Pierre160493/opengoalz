import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/players_sorting_function.dart';

class PlayerSortButton extends StatelessWidget {
  final List<Player> players;
  final VoidCallback onSort;

  const PlayerSortButton({
    Key? key,
    required this.players,
    required this.onSort,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Sort players by...',
      onPressed: () {
        showSortingOptions(context, (VoidCallback fn) {
          fn(); // Call the setState function
          onSort(); // Notify parent widget that sort occurred
        }, players);
      },
      icon: Icon(
        Icons.align_horizontal_left_rounded,
        size: iconSizeLarge,
        color: Colors.green,
      ),
    );
  }
}
