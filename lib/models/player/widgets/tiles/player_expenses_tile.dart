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
          Tooltip(
            message: 'Weekly expected expenses',
            child: Row(
              children: [
                Text(
                  player.expensesExpected.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (player.expensesMissed > 0)
            TextButton(
              onPressed: () => _showExpensesMissedDialog(context),
              child: Tooltip(
                message:
                    '${player.expensesMissed} missed expenses${player.expensesMissedToPayInPriority > 0 ? ' (${player.expensesMissedToPayInPriority} to pay in priority)' : ''}',
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
                      player.expensesMissed.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    if (player.expensesMissedToPayInPriority > 0)
                      Row(
                        children: [
                          formSpacer6,
                          Text(
                            '(${player.expensesMissedToPayInPriority.toString()})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        'Weekly Expenses',
        style: styleItalicBlueGrey,
      ),

      /// Show missed expenses warning button if there are any
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

    String? errorText; // Variable to hold error message

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
                        enabledBorder: buildBorder(Colors.orange),
                        focusedBorder: buildBorder(Colors.green),
                        suffixIcon: Tooltip(
                          message:
                              'Missed expenses are expected expenses that were not payed, it reduces the player\'s motivation',
                          child: Icon(Icons.info_outline, color: Colors.green),
                        ),
                      ),
                    ),

                    // Display missed expenses as a read-only TextField
                    formSpacer6,
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: player.expensesMissedToPayInPriority.toString(),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Current missed expenses to pay in priority',
                        prefixIcon: Icon(iconMoney, color: Colors.green),
                        enabledBorder: buildBorder(Colors.green),
                        focusedBorder: buildBorder(Colors.green),
                        suffixIcon: Tooltip(
                          message:
                              'Missed expenses to pay in priority will be payed at the end of week if the club has enough cash',
                          child: Icon(Icons.info_outline, color: Colors.green),
                        ),
                      ),
                    ),

                    /// Choose the amount to pay (with input)
                    formSpacer6,
                    TextField(
                      controller: _expensesMissedToPayInPriorityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            'Modify the missed expenses to pay in priority',
                        prefixIcon: Icon(iconMoney, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: errorText != null
                                ? Colors.red
                                : Colors.green, // Red border if error
                            width: 2,
                          ),
                        ),
                        suffixIcon: _expensesMissedToPayInPriorityController
                                    .text !=
                                player.expensesMissedToPayInPriority.toString()
                            ? IconButton(
                                icon: Icon(Icons.refresh,
                                    size: iconSizeSmall, color: Colors.grey),
                                tooltip:
                                    'Reset to current: ${player.expensesMissedToPayInPriority}',
                                onPressed: () {
                                  _expensesMissedToPayInPriorityController
                                          .text =
                                      player.expensesMissedToPayInPriority
                                          .toString();
                                  setState(() {
                                    errorText =
                                        null; // Clear error when resetting
                                  });
                                },
                              )
                            : null,
                        errorText: errorText, // Display error text if any
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        int? val = int.tryParse(value);
                        String sanitized =
                            (val == null || val < 0) ? '0' : val.toString();
                        if (_expensesMissedToPayInPriorityController.text !=
                            sanitized) {
                          _expensesMissedToPayInPriorityController.text =
                              sanitized;
                          _expensesMissedToPayInPriorityController.selection =
                              TextSelection.fromPosition(
                            TextPosition(offset: sanitized.length),
                          );
                        }
                        setState(() {
                          if (val != null && val > player.expensesMissed) {
                            errorText =
                                'Value cannot exceed the current missed expenses (${player.expensesMissed})';
                          } else {
                            errorText = null; // Clear error if input is valid
                          }
                        });
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
                      onPressed: (errorText == null &&
                              _expensesMissedToPayInPriorityController.text
                                      .trim() !=
                                  player.expensesMissedToPayInPriority
                                      .toString()
                                      .trim())
                          ? () {
                              int toPay = int.tryParse(
                                      _expensesMissedToPayInPriorityController
                                          .text
                                          .trim()) ??
                                  0;
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
        'expenses_missed_to_pay_in_priority': amountToPay,
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

  /// Add a helper method to build OutlineInputBorder
  OutlineInputBorder buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: 2,
      ),
    );
  }
}
