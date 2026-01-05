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
class PlayerAgeTile extends StatelessWidget {
  /// The player whose age information to display
  final Player player;

  const PlayerAgeTile({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Click to see player history',
      waitDuration: const Duration(milliseconds: 500),
      child: ListTile(
        shape: shapePersoRoundedBorder(),
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
        iconDead,
        size: iconSizeMedium,
        color: Colors.red,
      );
    } else {
      return Icon(
        Icons.cake_outlined,
        size: iconSizeMedium,
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
          style: TextStyle(
            fontSize: fontSizeSmall,
            fontStyle: FontStyle.italic,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  /// Returns formatted birth date string
  String _getFormattedBirthDate() {
    return DateFormat(persoDateFormat).format(player.dateBirth);
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
