import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/others/clubCashListTile.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/get_player_history_graph.dart';
import 'package:opengoalz/models/player/widgets/player_name_tooltip.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';
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
    // Color colorIfMissedExpenses =
    //     player.expensesMissed > player.expensesExpected
    //         ? Colors.red
    //         : player.expensesMissed > 0
    //             ? Colors.orange
    //             : Colors.green;
    return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Icon(
        iconMoney,
        // color: colorIfMissedExpenses,
        color: Colors.green,
        size: iconSizeMedium,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                player.expensesExpected.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (player.expensesMissed > 0)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showExpensesMissedDialog(context),
                child: Tooltip(
                  message: 'Missed expenses reducing player\'s motivation',
                  child: Row(
                    children: [
                      formSpacer6,
                      Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.red,
                        size: iconSizeSmall,
                      ),
                      formSpacer3,
                      Text(
                        '(${player.expensesMissed.toString()})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      subtitle: Tooltip(
        message: 'Weekly expected expenses of the player',
        child: Text(
          'Expected expenses',
          style: styleItalicBlueGrey,
        ),
      ),

      /// Show missed expenses warning button if there are any
      trailing: IconButton(
        tooltip: 'Check ${player.getPlayerNameString()} expenses history',
        onPressed: () => _showExpensesHistoryDialog(context),
        icon: Icon(iconHistory, size: iconSizeMedium, color: Colors.green),
      ),
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
  void _showExpensesMissedDialog(BuildContext context) {
    if (!_isPlayerOwnedByCurrentUser(context)) {
      context.showSnackBarError(
          'You are not the owner of ${player.firstName} ${player.lastName.toUpperCase()}\'s club');
      return;
    }

    final TextEditingController _expensesMissedToPayInPriorityController =
        TextEditingController(
      text: player.expensesMissedToPayInPriority.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final selectedClub =
            Provider.of<UserSessionProvider>(context, listen: false)
                .user
                .selectedClub!;
        return StatefulBuilder(
          builder: (context, setState) {
            return persoAlertDialogWithConstrainedContent(
              title: Row(
                children: [
                  Text('${player.expensesMissed} Missed Expenses for '),
                  PlayerNameTooltip(player: player),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    /// Display available cash in the club
                    getClubCashListTile(context, selectedClub),

                    formSpacer6,
                    // Display missed expenses as a read-only TextField
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: player.expensesMissed.toString(),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Missed expenses',
                        prefixIcon: Icon(iconMoney, color: Colors.orange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: player.expensesMissed > 0
                                ? Colors.orange
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: player.expensesMissed > 0
                                ? Colors.orange
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: player.expensesMissed > 0
                                ? Colors.orange
                                : Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        helperStyle: styleItalicBlueGrey,
                      ),
                    ),

                    /// Choose the amount to pay (with input)
                    formSpacer6,
                    TextField(
                      controller: _expensesMissedToPayInPriorityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Missed expenses to pay in priority',
                        prefixIcon: Icon(iconMoney, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: (int.tryParse(
                                            _expensesMissedToPayInPriorityController
                                                .text) ??
                                        0) >
                                    0
                                ? Colors.green
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: (int.tryParse(
                                            _expensesMissedToPayInPriorityController
                                                .text) ??
                                        0) >
                                    0
                                ? Colors.green
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: (int.tryParse(
                                            _expensesMissedToPayInPriorityController
                                                .text) ??
                                        0) >
                                    0
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        int? val = int.tryParse(value);
                        // Remove leading zeros by parsing and converting back to string
                        String sanitized =
                            (val == null || val < 0) ? '0' : val.toString();
                        if (_expensesMissedToPayInPriorityController.text !=
                            sanitized) {
                          _expensesMissedToPayInPriorityController.text =
                              sanitized;
                          // Move cursor to end
                          _expensesMissedToPayInPriorityController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                                offset: _expensesMissedToPayInPriorityController
                                    .text.length),
                          );
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: persoRowWithIcon(
                        iconSuccessfulOperation,
                        'Set ${_expensesMissedToPayInPriorityController.text} as missed expenses to pay in priority',
                        color: Colors.green,
                      ),
                      onPressed: (int.tryParse(
                                      _expensesMissedToPayInPriorityController
                                          .text) ??
                                  0) >
                              0
                          ? () {
                              int toPay = int.tryParse(
                                      _expensesMissedToPayInPriorityController
                                          .text) ??
                                  0;
                              if (toPay < 0) toPay = 0;
                              _payExpenses(context, toPay);
                            }
                          : null,
                    ),
                    TextButton(
                      child: persoCancelRow(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Pays the missed expenses for the player
  Future<void> _payExpenses(BuildContext context, int amountToPay) async {
    await operationInDB(
      context,
      'UPDATE',
      'players',
      data: {
        'expenses_missed_to_pay_in_advance':
            player.expensesMissedToPayInPriority
      },
      matchCriteria: {'id': player.id},
      messageSuccess:
          '${player.expensesMissedToPayInPriority} will be payed next week in priority if the club has enough cash',
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
          color: Colors.green,
        ),
        formSpacer3,
        Text(
          player.expensesExpected.toString(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
