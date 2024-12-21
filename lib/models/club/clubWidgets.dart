import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/widgets/financesGraphDialogBox.dart';
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
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return FinancesGraphDialog(
            nameCurves: 'Cash',
            dataPoints: club.lisCash,
          );

          // final chartData = ChartData(
          //   xAxisLabel: 'Time (in weeks)',
          //   yAxisLabel: 'Cash',
          //   // xValues: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
          //   yValues: club.lisCash.map((e) => e.toDouble()).toList(),
          // );

          // return Container(
          //   height: 300,
          //   width: 300,
          //   // height: MediaQuery.of(context).size.height * 0.8,
          //   // width: MediaQuery.of(context).size.width * 0.8,
          //   child: PlayerLineChart(chartData: chartData),
          // );
        },
      );
    },
  );
}
