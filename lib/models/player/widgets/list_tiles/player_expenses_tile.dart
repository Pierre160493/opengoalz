import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/get_player_history_graph.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

/// Widget that displays a player's expenses information as a ListTile
///
/// Shows:
/// - Expected weekly expenses with money icon
/// - Red warning if there are missed expenses with action button
/// - Clickable to show expenses history graph
/// - Pay expenses functionality for club owners
class PlayerExpensesTile extends StatelessWidget {
  /// The player whose expenses to display
  final Player player;

  const PlayerExpensesTile({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Icon(
        iconMoney,
        color: Colors.green,
        size: iconSizeMedium,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildExpensesDisplay(),
          if (_buildMissedExpensesButton(context) != null)
            _buildMissedExpensesButton(context)!,
        ],
      ),
      subtitle: Tooltip(
        message: 'Weekly expected expenses of the player',
        child: Text(
          'Expected expenses',
          style: styleItalicBlueGrey,
        ),
      ),
      onTap: () => _showExpensesHistoryDialog(context),
    );
  }

  /// Shows the expenses history graph dialog
  void _showExpensesHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return getPlayerHistoryGraph(
          context,
          player.id,
          ['expenses_expected', 'expenses_target'],
          'Weekly Expenses (expected and target)',
        );
      },
    );
  }

  /// Shows the pay expenses dialog for missed payments
  void _showPayExpensesDialog(BuildContext context) {
    if (!_isPlayerOwnedByCurrentUser(context)) {
      context.showSnackBarError(
          'You are not the owner of ${player.firstName} ${player.lastName.toUpperCase()}\'s club');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Past expenses not payed'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Icon(iconMoney, color: Colors.red),
                      Text(
                        ' ${player.expensesMissed.toString()}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Text('Total amount of unpaid expenses',
                      style: styleItalicBlueGrey),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(iconMoney, color: Colors.green),
                      Text(
                        ' ${Provider.of<UserSessionProvider>(context, listen: false).user.selectedClub!.clubData.cash.toString()}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Text('Available cash', style: styleItalicBlueGrey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Pay expenses'),
              onPressed: () => _payExpenses(context),
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Pays the missed expenses for the player
  Future<void> _payExpenses(BuildContext context) async {
    await operationInDB(
      context,
      'UPDATE',
      'players',
      data: {'expenses_missed': 0},
      matchCriteria: {'id': player.id},
      messageSuccess:
          'Successfully payed ${player.getFullName()} missed expenses',
    );
    Navigator.of(context).pop();
  }

  /// Checks if the current user owns the player's club
  bool _isPlayerOwnedByCurrentUser(BuildContext context) {
    return Provider.of<UserSessionProvider>(context, listen: false)
            .user
            .selectedClub!
            .id ==
        player.idClub;
  }

  /// Builds the expenses display with icon and amount
  Widget _buildExpensesDisplay() {
    return Row(
      children: [
        Icon(
          iconMoney,
          size: iconSizeMedium,
          color: player.expensesExpected > 0
              ? player.expensesMissed > 0
                  ? Colors.red
                  : Colors.green
              : Colors.blueGrey,
        ),
        formSpacer3,
        Text(
          player.expensesExpected.toString(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Builds the missed expenses warning button
  Widget? _buildMissedExpensesButton(BuildContext context) {
    if (player.expensesMissed <= 0) return null;

    return IconButton(
      tooltip: 'Past expenses not payed ${player.expensesMissed.toString()}',
      onPressed: () => _showPayExpensesDialog(context),
      icon: Icon(Icons.money_off, color: Colors.red),
    );
  }
}
