import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/widgets/financesGraphDialogBox.dart';

Widget getClubCashListTile(BuildContext context, Club club) {
  return ListTile(
    shape: shapePersoRoundedBorder(),
    leading: Icon(iconCash,
        color: club.cash >= 0 ? Colors.green : Colors.red,
        size: iconSizeMedium),
    title: Row(
      children: [
        Icon(iconMoney),
        formSpacer3,
        Text(
          NumberFormat.decimalPattern().format(club.cash).replaceAll(',', ' '),
          style: TextStyle(
              color: club.cash >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold),
        ),
      ],
    ),
    subtitle: Text(
      'Club\'s Available Cash',
      style: styleItalicBlueGrey,
    ),
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return FinancesGraphDialog(
            nameCurves: 'Cash',
            dataPoints: club.lisCash,
          );
        },
      );
    },
  );
}
