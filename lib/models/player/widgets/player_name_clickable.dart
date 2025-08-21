import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/player_name_tooltip.dart';
import 'package:opengoalz/models/player/pages/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';

/// Widget that displays a clickable player name
///
/// Shows:
/// - Player name as a clickable element
/// - Navigates to player details page when tapped
/// - Uses PlayerNameTooltip for display
/// - Supports surname display mode
class PlayerNameClickable extends StatelessWidget {
  /// The player whose name to display
  final Player player;

  /// Whether to align to the right (default: false)
  final bool isRightClub;

  /// Whether to display the surname instead of initial.lastname format
  final bool isSurname;

  /// Optional custom tooltip widget
  final Widget? customTooltip;

  /// Optional callback for custom navigation behavior
  final VoidCallback? onTap;

  const PlayerNameClickable({
    super.key,
    required this.player,
    this.isRightClub = false,
    this.isSurname = false,
    this.customTooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isRightClub ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap ?? () => _defaultNavigateToPlayer(context),
          child: customTooltip ??
              PlayerNameTooltip(
                player: player,
                isSurname: isSurname,
              ),
        ),
      ],
    );
  }

  /// Default navigation behavior to player details page
  void _defaultNavigateToPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayersPage(
          playerSearchCriterias: PlayerSearchCriterias(idPlayer: [player.id]),
        ),
      ),
    );
  }
}
