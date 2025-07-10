import 'dart:math';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/widgets/graphWidget.dart';

/// Widget that displays a player's stat with a linear progress indicator
///
/// Shows:
/// - Icon representing the stat type
/// - Stat label with fixed width
/// - Linear progress bar showing current vs previous value
/// - Clickable to show detailed stat history chart
///
/// Supports various stat types like Motivation, Stamina, Form, etc.
class PlayerStatLinearWidget extends StatelessWidget {
  /// The player whose stat to display
  final Player player;

  /// The stat label (e.g., 'Motivation', 'Stamina', etc.)
  final String label;

  /// List of all historical stat values
  final List<double> statsHistoryAll;

  /// Week offset to compare current value with previous value
  final int weekOffsetToCompareWithNow;

  /// Optional custom shape for the ListTile
  final ShapeBorder? customShape;

  /// Optional custom icon size
  final double? iconSize;

  /// Optional custom label width
  final double? labelWidth;

  const PlayerStatLinearWidget({
    super.key,
    required this.player,
    required this.label,
    required this.statsHistoryAll,
    required this.weekOffsetToCompareWithNow,
    this.customShape,
    this.iconSize,
    this.labelWidth,
  });

  @override
  Widget build(BuildContext context) {
    final statInfo = _getStatInfo();
    final values = _calculateValues();

    return ListTile(
      shape: customShape ?? shapePersoRoundedBorder(),
      leading: Tooltip(
        message: statInfo.tooltip,
        child: Icon(
          statInfo.icon,
          size: iconSize ?? iconSizeSmall,
          color: _getIconColor(values.current),
        ),
      ),
      title: Row(
        children: [
          formSpacer6,
          SizedBox(
            width: labelWidth ?? 100,
            child: Text(label),
          ),
        ],
      ),
      subtitle: _buildProgressBars(values),
      onTap: () => _showStatHistoryChart(context),
    );
  }

  /// Gets the icon and tooltip for the given stat label
  _StatInfo _getStatInfo() {
    switch (label) {
      case 'Motivation':
        return _StatInfo(iconMotivation, 'How motivated the player is');
      case 'Stamina':
        return _StatInfo(iconStamina, 'How much stamina the player has');
      case 'Form':
        return _StatInfo(iconForm, 'How good the player is currently playing');
      case 'Experience':
        return _StatInfo(iconExperience, 'How experienced the player is');
      case 'Energy':
        return _StatInfo(iconEnergy, 'How much energy the player has');
      case 'Loyalty':
        return _StatInfo(Icons.loyalty, 'How loyal the player is to the club');
      case 'Leadership':
        return _StatInfo(
            Icons.leaderboard, 'How good the player is at leading');
      case 'Discipline':
        return _StatInfo(Icons.gavel, 'How disciplined the player is');
      case 'Communication':
        return _StatInfo(Icons.chat, 'How good the player is at communicating');
      case 'Aggressivity':
        return _StatInfo(Icons.sports_mma, 'How aggressive the player is');
      case 'Composure':
        return _StatInfo(Icons.self_improvement,
            'How well the player responds under pressure');
      case 'Teamwork':
        return _StatInfo(
            Icons.group, 'How good the player is for playing in a team');
      default:
        return _StatInfo(iconBug, 'Unknown stat');
    }
  }

  /// Calculates current and old stat values
  _StatValues _calculateValues() {
    final current = statsHistoryAll.last;
    final old = statsHistoryAll[
        statsHistoryAll.length - 1 - weekOffsetToCompareWithNow];
    return _StatValues(current, old);
  }

  /// Gets the appropriate color based on stat value
  Color _getIconColor(double value) {
    if (value > 50) return Colors.green;
    if (value > 20) return Colors.orange;
    return Colors.red;
  }

  /// Builds the stacked progress bars showing current vs previous values
  Widget _buildProgressBars(_StatValues values) {
    return Stack(
      children: [
        // Background bar (only if values are different)
        if (values.current != values.old)
          SizedBox(
            height: 12,
            child: LinearProgressIndicator(
              value: max(values.current, values.old) / 100,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(
                values.current > values.old ? Colors.green : Colors.red,
              ),
            ),
          ),
        // Foreground bar
        SizedBox(
          height: 12,
          child: LinearProgressIndicator(
            value: min(values.current, values.old) / 100,
            backgroundColor:
                values.current != values.old ? Colors.transparent : Colors.grey,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ],
    );
  }

  /// Shows the stat history chart dialog
  void _showStatHistoryChart(BuildContext context) {
    final chartData = ChartData(
      title: 'Player $label History',
      yValues: [statsHistoryAll],
      typeXAxis: XAxisType.weekHistory,
      minY: 0,
      maxY: 100,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChartDialogBox(chartData: chartData);
      },
    );
  }
}

/// Helper class to hold stat icon and tooltip information
class _StatInfo {
  final IconData icon;
  final String tooltip;

  const _StatInfo(this.icon, this.tooltip);
}

/// Helper class to hold current and old stat values
class _StatValues {
  final double current;
  final double old;

  const _StatValues(this.current, this.old);
}
