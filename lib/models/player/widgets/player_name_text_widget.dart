import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';

/// Widget that displays a player's name as a formatted text
///
/// Shows:
/// - First initial and uppercase last name (default)
/// - Full surname if isSurname is true
/// - Color coding based on player ownership:
///   - Colored if embodied by current user
///   - Different color if part of current user's club
///   - Default color otherwise
class PlayerNameTextWidget extends StatelessWidget {
  /// The player whose name to display
  final Player player;

  /// Whether to display the surname instead of initial.lastname format
  final bool isSurname;

  /// Optional custom text style
  final TextStyle? customStyle;

  /// Optional max lines (default: 1)
  final int? maxLines;

  /// Optional text overflow behavior (default: TextOverflow.fade)
  final TextOverflow? overflow;

  const PlayerNameTextWidget({
    super.key,
    required this.player,
    this.isSurname = false,
    this.customStyle,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = isSurname
        ? player.surName ?? 'No Surname'
        : '${player.firstName[0]}.${player.lastName.toUpperCase()}';

    final TextStyle effectiveStyle = customStyle?.copyWith(
          fontWeight: FontWeight.bold,
          color: customStyle?.color ?? _getNameColor(),
        ) ??
        TextStyle(
          fontWeight: FontWeight.bold,
          color: _getNameColor(),
        );

    return Text(
      displayName,
      style: effectiveStyle,
      overflow: overflow ?? TextOverflow.fade,
      maxLines: maxLines ?? 1,
      softWrap: false,
    );
  }

  /// Determines the color based on player ownership status
  Color? _getNameColor() {
    if (player.isEmbodiedByCurrentUser) {
      return colorIsMine;
    } else if (player.isPartOfClubOfCurrentUser) {
      return colorIsSelected;
    }
    return null; // Default theme color
  }
}
