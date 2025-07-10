import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';

/// Widget that displays a player's injury information
///
/// Shows:
/// - Red injury icon
/// - Number of days remaining for recovery
/// - Recovery text description
///
/// Note: Should only be displayed when player.dateEndInjury is not null
class PlayerInjuryTile extends StatelessWidget {
  /// The player whose injury information to display
  final Player player;

  const PlayerInjuryTile({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    // Safety check - should not be null when this widget is used
    if (player.dateEndInjury == null) {
      return const SizedBox.shrink();
    }

    final daysLeft = _calculateDaysLeft();

    return Row(
      children: [
        Icon(
          Icons.personal_injury_outlined,
          size: iconSizeSmall,
          color: Colors.red,
        ),
        Text(
          ' $daysLeft',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          ' days left for recovery',
        ),
      ],
    );
  }

  /// Calculates the number of days left for recovery
  String _calculateDaysLeft() {
    final daysLeft = player.dateEndInjury!.difference(DateTime.now()).inDays;
    return daysLeft.toString();
  }
}
