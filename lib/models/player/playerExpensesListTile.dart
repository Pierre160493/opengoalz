import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerWidgets.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

Widget getExpensesWidget(BuildContext context, Player player) {
  return ListTile(
    shape: shapePersoRoundedBorder(),
    leading: Icon(
      iconMoney,
      color: Colors.green,
      size: iconSizeMedium, // Adjust icon size as needed
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (player.expensesMissed > 0)
          IconButton(
            tooltip:
                'Past expenses not payed ${player.expensesMissed.toString()}',
            onPressed: () {
              if (Provider.of<UserSessionProvider>(context, listen: false)
                      .user
                      .selectedClub!
                      .id ==
                  player.idClub) {
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              subtitle: Text('Available cash',
                                  style: styleItalicBlueGrey),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Pay expenses'),
                          onPressed: () async {
                            bool isOK = await operationInDB(
                                context, 'UPDATE', 'players',
                                data: {'expenses_missed': 0},
                                matchCriteria: {'id': player.id});
                            if (isOK) {
                              context.showSnackBar(
                                  'Successfully payed ${player.firstName} ${player.lastName.toUpperCase()} missed expenses',
                                  icon: Icon(iconSuccessfulOperation,
                                      color: Colors.green));
                            }
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                context.showSnackBarError(
                    'You are not the owner of ${player.firstName} ${player.lastName.toUpperCase()}\'s club');
              }
            },
            icon: Icon(Icons.money_off, color: Colors.red),
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
    onTap: () => showDialog(
      context: context,
      builder: (BuildContext context) {
        return getPlayerHistoryStreamGraph(
          context,
          player.id,
          ['expenses_expected', 'expenses_target'],
          'Weekly Expenses (expected and target)',
        );
      },
    ),
  );
}
