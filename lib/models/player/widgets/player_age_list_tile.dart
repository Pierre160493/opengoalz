import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/AgeAndBirth.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/pages/player_history_page.dart';

/// Widget that displays a player's age and birth date information as a ListTile
///
/// Shows:
/// - Death icon (red) if player is deceased, or cake icon (green) if alive
/// - Player's current age
/// - Birth date in formatted string
/// - Clickable to navigate to player history page
/// - Tooltip with instruction to click for history
class PlayerAgeListTile extends StatelessWidget {
  /// The player whose age information to display
  final Player player;

  /// Optional custom shape for the ListTile
  final ShapeBorder? customShape;

  /// Optional custom icon for living players
  final IconData? aliveIcon;

  /// Optional custom icon for deceased players
  final IconData? deadIcon;

  /// Optional custom date format
  final String? customDateFormat;

  /// Optional tooltip message
  final String? tooltipMessage;

  const PlayerAgeListTile({
    Key? key,
    required this.player,
    this.customShape,
    this.aliveIcon,
    this.deadIcon,
    this.customDateFormat,
    this.tooltipMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipMessage ?? 'Click to see player history',
      waitDuration: const Duration(milliseconds: 500),
      child: ListTile(
        shape: customShape ?? shapePersoRoundedBorder(),
        leading: _buildLeadingIcon(),
        title: Row(
          children: [
            getAgeStringRow(player.age),
          ],
        ),
        subtitle: _buildSubtitle(),
        onTap: () => _navigateToPlayerHistory(context),
      ),
    );
  }

  /// Builds the leading icon based on player's life status
  Widget _buildLeadingIcon() {
    if (player.dateDeath != null) {
      return Icon(
        deadIcon ?? iconDead,
        size: iconSizeLarge,
        color: Colors.red,
      );
    } else {
      return Icon(
        aliveIcon ?? Icons.cake_outlined,
        size: iconSizeLarge,
        color: Colors.green,
      );
    }
  }

  /// Builds the subtitle showing birth date
  Widget _buildSubtitle() {
    return Row(
      children: [
        Icon(
          Icons.event,
          size: iconSizeSmall,
          color: Colors.green,
        ),
        formSpacer3,
        Text(
          _getFormattedBirthDate(),
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  /// Returns formatted birth date string
  String _getFormattedBirthDate() {
    final dateFormat = customDateFormat ?? persoDateFormat;
    return DateFormat(dateFormat).format(player.dateBirth);
  }

  /// Navigates to the player history page
  void _navigateToPlayerHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerHistoryPage(player: player),
      ),
    );
  }
}
