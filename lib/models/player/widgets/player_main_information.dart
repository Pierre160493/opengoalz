import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/tiles/player_age_tile.dart';
import 'package:opengoalz/models/player/widgets/tiles/player_injury_tile.dart';
import 'package:opengoalz/models/player/widgets/tiles/player_performance_score_tile.dart';
import 'package:opengoalz/widgets/country_tile.dart';
import 'package:opengoalz/models/player/widgets/tiles/player_expenses_tile.dart';
import 'package:opengoalz/models/player/transfer/player_transfer_list_tile.dart';
import 'package:opengoalz/models/player/widgets/tiles/player_embodied_tile.dart';

/// Widget that displays a player's main information in a responsive layout
///
/// Shows different layouts based on screen width:
/// - Larger screens: Two-column layout with paired information
/// - Smaller screens: Single-column layout with stacked information
///
/// Displays:
/// - Age information
/// - Country information
/// - Performance score
/// - Expenses
/// - Transfer information (if applicable)
/// - Embodied user info (if applicable, small screens only)
/// - Injury information (if applicable)
class PlayerMainInformation extends StatelessWidget {
  /// The player whose information to display
  final Player player;

  const PlayerMainInformation({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > maxWidth / 2) {
          return _buildLargeScreenLayout(context);
        } else {
          return _buildSmallScreenLayout(context);
        }
      },
    );
  }

  /// Builds the layout for larger screens (two-column layout)
  Widget _buildLargeScreenLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: PlayerAgeTile(player: player)),
            Expanded(
              child: CountryTileFromId(
                idCountry: player.idCountry,
                idMultiverse: player.idMultiverse,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child: PlayerPerformanceScoreTile(player: player)),
            Expanded(
                child: PlayerExpensesTile(
              player: player,
            )),
          ],
        ),

        /// If the player is on the transfer list, show transfer information
        if (player.dateBidEnd != null) PlayerTransferTile(player: player),

        /// If the player is injured, show injury information
        if (player.dateEndInjury != null) PlayerInjuryTile(player: player),
      ],
    );
  }

  /// Builds the layout for smaller screens (single-column layout)
  Widget _buildSmallScreenLayout(BuildContext context) {
    return Column(
      children: [
        PlayerAgeTile(player: player),
        CountryTileFromId(
          idCountry: player.idCountry,
          idMultiverse: player.idMultiverse,
        ),
        PlayerPerformanceScoreTile(player: player),
        PlayerExpensesTile(
          player: player,
        ),
        if (player.dateBidEnd != null) PlayerTransferTile(player: player),
        if (player.userName != null) PlayerEmbodiedTile(player: player),
        if (player.dateEndInjury != null) PlayerInjuryTile(player: player),
      ],
    );
  }
}
