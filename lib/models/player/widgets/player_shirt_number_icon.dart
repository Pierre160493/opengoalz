import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/dialogs/player_shirt_number_dialog_box.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

/// Widget that displays a player's shirt number with an interactive icon
///
/// Shows:
/// - Red icon if no shirt number assigned
/// - Green icon with number if shirt number exists
/// - Clickable only if the player belongs to the user's selected club
/// - Opens shirt number dialog when tapped (if editable)
class PlayerShirtNumberIcon extends StatelessWidget {
  /// The player whose shirt number to display
  final Player player;

  /// Optional custom icon for the shirt
  final IconData? customIcon;

  /// Optional custom colors for different states
  final Color? noNumberColor;
  final Color? hasNumberColor;

  const PlayerShirtNumberIcon({
    Key? key,
    required this.player,
    this.customIcon,
    this.noNumberColor,
    this.hasNumberColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPlayerClubSelected = _isPlayerClubSelected(context);

    return InkWell(
      onTap:
          isPlayerClubSelected ? () => _openShirtNumberDialog(context) : null,
      child: Tooltip(
        message: _getTooltipMessage(),
        child: Row(
          children: [
            Icon(
              customIcon ?? iconShirt,
              color: _getIconColor(),
              size: iconSizeSmall,
            ),
            if (player.shirtNumber != null) _buildShirtNumberText(),
          ],
        ),
      ),
    );
  }

  /// Checks if the player belongs to the user's currently selected club
  bool _isPlayerClubSelected(BuildContext context) {
    return Provider.of<UserSessionProvider>(context, listen: false)
            .user
            .selectedClub!
            .id ==
        player.idClub;
  }

  /// Opens the shirt number dialog for editing
  void _openShirtNumberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PlayerShirtNumberDialogBox(player: player),
    );
  }

  /// Returns appropriate tooltip message based on shirt number status
  String _getTooltipMessage() {
    return player.shirtNumber == null
        ? 'No Shirt Number '
        : 'Shirt number: ${player.shirtNumber}';
  }

  /// Returns appropriate icon color based on shirt number status
  Color _getIconColor() {
    return player.shirtNumber == null
        ? (noNumberColor ?? Colors.red)
        : (hasNumberColor ?? Colors.green);
  }

  /// Builds the shirt number text widget
  Widget _buildShirtNumberText() {
    return Text(
      player.shirtNumber.toString(),
      style: TextStyle(
        fontSize: fontSizeSmall,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
