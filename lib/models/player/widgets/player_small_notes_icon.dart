import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/dialogs/player_notes_dialog_box.dart';

/// Widget that displays a player's small notes count with an interactive icon
///
/// Shows:
/// - Green notes icon with the count of small notes
/// - Clickable to open notes dialog for viewing/editing
/// - Tooltip showing the actual notes content
class PlayerSmallNotesIcon extends StatelessWidget {
  /// The player whose notes to display
  final Player player;

  /// Optional custom icon for notes
  final IconData? customIcon;

  /// Optional custom color for the icon
  final Color? iconColor;

  /// Optional custom text style for the notes count
  final TextStyle? countTextStyle;

  const PlayerSmallNotesIcon({
    Key? key,
    required this.player,
    this.customIcon,
    this.iconColor,
    this.countTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openNotesDialog(context),
      child: Tooltip(
        message: _getTooltipMessage(),
        child: Row(
          children: [
            Icon(
              customIcon ?? iconNotesSmall,
              color: iconColor ?? Colors.green,
            ),
            _buildNotesCountText(),
          ],
        ),
      ),
    );
  }

  /// Opens the notes dialog for viewing/editing player notes
  void _openNotesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PlayerNotesDialogBox(player: player),
    );
  }

  /// Returns tooltip message showing the player's notes
  String _getTooltipMessage() {
    return 'Notes: ${player.notes}';
  }

  /// Builds the notes count text widget
  Widget _buildNotesCountText() {
    return Text(
      player.notesSmall.toString(),
      style: countTextStyle ??
          const TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
