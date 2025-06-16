import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/class/club_data.dart';
// Import Supabase package

Widget getClubCashListTile(BuildContext context, Club club) {
  return ListTile(
    shape: shapePersoRoundedBorder(),
    leading: Icon(iconCash,
        color: club.clubData.cash >= 0 ? Colors.green : Colors.red,
        size: iconSizeMedium),
    title: Row(
      children: [
        Icon(iconMoney),
        formSpacer3,
        Text(
          NumberFormat.decimalPattern()
              .format(club.clubData.cash)
              .replaceAll(',', ' '),
          style: TextStyle(
              color: club.clubData.cash >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold),
        ),
      ],
    ),
    subtitle: Text(
      'Available Cash',
      style: styleItalicBlueGrey,
    ),
    onTap: () async {
      ClubData.showClubDataHistoryChartDialog(
        context,
        club.id,
        'cash',
        'Weekly Cash',
        dataToAppend: club.clubData.cash,
      );
    },
  );
}
