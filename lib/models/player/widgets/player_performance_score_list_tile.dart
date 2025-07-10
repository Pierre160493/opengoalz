import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/get_player_history_graph.dart';

/// Widget that displays a player's performance score as a clickable ListTile
///
/// Shows:
/// - Performance score value (rounded to nearest integer)
/// - Stats icon with green color
/// - "Performance Score" subtitle
/// - Clickable to show performance history graph dialog
class PlayerPerformanceScoreListTile extends StatelessWidget {
  /// The player whose performance score to display
  final Player player;

  /// Optional custom shape for the ListTile
  final ShapeBorder? customShape;

  /// Optional custom icon for the performance score
  final IconData? customIcon;

  /// Optional custom icon size
  final double? iconSize;

  /// Optional custom icon color
  final Color? iconColor;

  /// Optional custom title text style
  final TextStyle? titleStyle;

  /// Optional custom subtitle text style
  final TextStyle? subtitleStyle;

  const PlayerPerformanceScoreListTile({
    super.key,
    required this.player,
    this.customShape,
    this.customIcon,
    this.iconSize,
    this.iconColor,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: customShape ?? shapePersoRoundedBorder(),
      leading: Icon(
        customIcon ?? iconStats,
        size: iconSize ?? iconSizeMedium,
        color: iconColor ?? Colors.green,
      ),
      title: Text(
        player.performanceScoreReal.toStringAsFixed(0),
        style: titleStyle ??
            const TextStyle(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        'Performance Score',
        style: subtitleStyle ?? styleItalicBlueGrey,
      ),
      onTap: () => _showPerformanceHistoryDialog(context),
    );
  }

  /// Shows the performance history graph dialog
  void _showPerformanceHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return getPlayerHistoryGraph(
          context,
          player.id,
          ['performance_score_real', 'performance_score_theoretical'],
          'Weekly Performance Score (Real and theoretical)',
        );
      },
    );
  }
}
