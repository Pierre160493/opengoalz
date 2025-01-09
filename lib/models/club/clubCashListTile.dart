import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/widgets/graphWidget.dart';

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
      'Available Cash',
      style: styleItalicBlueGrey,
    ),
    onTap: () async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final chartData = ChartData(
            title: 'Available Cash History (per weeks)',
            yValues: [club.lisCash.map((e) => e.toDouble()).toList()],
            typeXAxis: XAxisType.weekHistory,
          );

          return ChartDialogBox(chartData: chartData);
        },
      );
    },
  );
}
