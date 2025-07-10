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
class PlayerInjuryWidget extends StatelessWidget {
  /// The player whose injury information to display
  final Player player;

  /// Optional custom icon for injury
  final IconData? customIcon;

  /// Optional custom icon size
  final double? iconSize;

  /// Optional custom icon color
  final Color? iconColor;

  /// Optional custom text style for days count
  final TextStyle? daysTextStyle;

  /// Optional custom text style for recovery text
  final TextStyle? recoveryTextStyle;

  /// Optional custom recovery text
  final String? customRecoveryText;

  const PlayerInjuryWidget({
    super.key,
    required this.player,
    this.customIcon,
    this.iconSize,
    this.iconColor,
    this.daysTextStyle,
    this.recoveryTextStyle,
    this.customRecoveryText,
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
          customIcon ?? Icons.personal_injury_outlined,
          size: iconSize ?? iconSizeSmall,
          color: iconColor ?? Colors.red,
        ),
        Text(
          ' $daysLeft',
          style: daysTextStyle ??
              const TextStyle(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          customRecoveryText ?? ' days left for recovery',
          style: recoveryTextStyle,
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
