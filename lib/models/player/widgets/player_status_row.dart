import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/pages/game_page.dart';

/// Widget that displays the status indicators for a player
///
/// Shows various status icons with overlaid text for:
/// - Transfer list status with countdown
/// - Injury status with days remaining
/// - Retirement status
/// - Death status
/// - Currently playing indicator
/// - Staff member indicator
class PlayerStatusRow extends StatelessWidget {
  /// The player whose status should be displayed
  final Player player;

  const PlayerStatusRow({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime currentDate = DateTime.now().toLocal();

    return Row(
      children: [
        // Transfer list status
        if (player.dateBidEnd != null) ...[
          _buildTransferStatusIcon(currentDate),
        ],

        // Injury status
        if (player.dateEndInjury != null) _buildInjuryStatusIcon(currentDate),

        // Retirement status
        if (player.dateRetire != null) _buildRetirementStatusIcon(),

        // Death status
        if (player.dateDeath != null) _buildDeathStatusIcon(),

        // Currently playing indicator
        _buildPlayingStatusIcon(context, player),

        // Staff member indicator
        if (player.isStaff) _buildStaffStatusIcon(),
      ],
    );
  }

  /// Builds the transfer status icon with countdown overlay
  Widget _buildTransferStatusIcon(DateTime currentDate) {
    final difference = player.dateBidEnd!.difference(currentDate);
    final countdownText = difference.inDays >= 1
        ? '${difference.inDays}d'
        : '${difference.inHours}h';

    return Tooltip(
      message:
          'Auction deadline: ${DateFormat('EEE d \'at\' H:mm').format(player.dateBidEnd!)}',
      child: Stack(
        children: [
          Icon(
            _getTransferIcon(),
            color: Colors.red,
            size: 30.0, // iconSizeMedium
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              countdownText,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the injury status icon with days remaining overlay
  Widget _buildInjuryStatusIcon(DateTime currentDate) {
    final daysRemaining = player.dateEndInjury!.difference(currentDate).inDays;

    return Tooltip(
      message: 'Injured for $daysRemaining more days',
      child: Stack(
        children: [
          const Icon(
            Icons.local_hospital,
            color: Colors.red,
            size: 30.0, // iconSizeMedium
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              daysRemaining.toString(),
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the retirement status icon
  Widget _buildRetirementStatusIcon() {
    return Tooltip(
      message:
          'Retired on ${DateFormat('EEE d MMM yyyy').format(player.dateRetire!)}',
      child: Icon(
        iconRetired,
        color: Colors.red,
        size: 30.0, // iconSizeMedium
      ),
    );
  }

  /// Builds the death status icon
  Widget _buildDeathStatusIcon() {
    return Tooltip(
      message:
          'Died on ${DateFormat('EEE d MMM yyyy').format(player.dateDeath!)}',
      child: Icon(
        iconDead,
        color: Colors.red,
        size: 30.0, // iconSizeMedium
      ),
    );
  }

  /// Builds the currently playing status icon
  Widget _buildPlayingStatusIcon(BuildContext context, Player player) {
    if (player.idGameCurrentlyPlaying == null) {
      return SizedBox.shrink();
    }
    return Tooltip(
      message: 'Currently playing a game',
      child: IconButton(
        icon: Icon(
          Icons.directions_run_outlined,
          color: Colors.green,
          size: 30.0, // iconSizeMedium
        ),
        onPressed: () {
          // Navigate to the game details page
          Navigator.of(context).push(
              GamePage.route(player.idGameCurrentlyPlaying!, player.idClub));
        },
      ),
    );
  }

  /// Builds the staff member status icon
  Widget _buildStaffStatusIcon() {
    return Tooltip(
      message: 'Is a staff member',
      child: Icon(
        iconStaff,
        color: Colors.green,
        size: 30.0, // iconSizeMedium
      ),
    );
  }

  /// Determines the appropriate transfer icon based on player status
  IconData _getTransferIcon() {
    if (player.idClub == null) {
      return iconFreePlayer;
    } else if (player.transferPrice != null && player.transferPrice! < 0) {
      return iconLeaveClub;
    } else {
      return iconTransfers;
    }
  }
}
