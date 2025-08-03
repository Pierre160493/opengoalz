import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/others/clubCashListTile.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/get_player_history_graph.dart';
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
    Color colorIfMissedExpenses =
        player.expensesMissed > 0 ? Colors.orange : Colors.green;
    return ListTile(
      shape: shapePersoRoundedBorder(colorIfMissedExpenses),
      leading: Icon(
        iconMoney,
        color: colorIfMissedExpenses,
        size: iconSizeMedium,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildExpensesDisplay(),
        ],
      ),
      subtitle: Tooltip(
        message: 'Weekly expected expenses of the player',
        child: Text(
          'Expected expenses',
          style: styleItalicBlueGrey,
        ),
      ),
      trailing: player.expensesMissed > 0
          ? _buildMissedExpensesButton(context)
          : null,
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

    final Club selectedClub =
        Provider.of<UserSessionProvider>(context, listen: false)
            .user
            .selectedClub!;
    final TextEditingController _payController = TextEditingController(
      text: player.expensesMissed.toString(),
    );
    // Cap maxPayable by both missed expenses and club cash
    int maxPayable = min(player.expensesMissed, selectedClub.clubData.cash);

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
              title: Text(
                  '${player.expensesMissed} Past expenses not payed for ${player.getFullName()}'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    /// Display available cash in the club
                    getClubCashListTile(context, selectedClub),

                    /// Display missed expenses
                    ListTile(
                      shape: shapePersoRoundedBorder(),
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

                    /// Display expected expenses
                    ListTile(
                      shape: shapePersoRoundedBorder(),
                      title: Row(
                        children: [
                          Icon(iconMoney, color: Colors.green),
                          Text(
                            ' ${player.expensesExpected.toString()}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      subtitle: Text('Expected weekly expenses',
                          style: styleItalicBlueGrey),
                    ),

                    /// Choose the amount to pay (with input)
                    ListTile(
                      shape: shapePersoRoundedBorder(),
                      title: GestureDetector(
                        onTap: () {
                          _payController.text =
                              player.expensesMissed.toString();
                          _payController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _payController.text.length),
                          );
                        },
                        child: Text(
                          'Pay the ${player.expensesMissed} missed expenses',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          formSpacer6,
                          TextField(
                            controller: _payController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Amount to pay (max $maxPayable)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      (int.tryParse(_payController.text) ?? 0) >
                                              0
                                          ? Colors.green
                                          : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      (int.tryParse(_payController.text) ?? 0) >
                                              0
                                          ? Colors.green
                                          : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: (int.tryParse(_payController.text) ??
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
                              String sanitized = (val == null || val < 0)
                                  ? '0'
                                  : val.toString();
                              if (val != null && val > maxPayable) {
                                sanitized = maxPayable.toString();
                                val = maxPayable;
                              }
                              if (_payController.text != sanitized) {
                                _payController.text = sanitized;
                                // Move cursor to end
                                _payController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: _payController.text.length),
                                );
                              }
                              setState(() {});
                            },
                          ),
                        ],
                      ),
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
                        'Pay ${_payController.text} missed expenses',
                        color: Colors.green,
                      ),
                      onPressed: (int.tryParse(_payController.text) ?? 0) > 0
                          ? () {
                              int toPay =
                                  int.tryParse(_payController.text) ?? 0;
                              if (toPay < 0) toPay = 0;
                              if (toPay > maxPayable) toPay = maxPayable;
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
        // 'expenses_payed': player.expensesPayed + amountToPay,
        'expenses_missed': player.expensesMissed - amountToPay
      },
      matchCriteria: {'id': player.id},
      messageSuccess:
          'Successfully payed $amountToPay missed expenses for ${player.getFullName()}',
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
