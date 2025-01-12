import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/class/club_data.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase package

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
      final List<num>? cashHistory =
          await ClubData.fetchClubDataHistory(context, club.id, 'cash');

      if (cashHistory != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final chartData = ChartData(
              title: 'Available Cash History (per weeks)',
              yValues: [
                [...cashHistory, club.clubData.cash]
              ],
              typeXAxis: XAxisType.weekHistory,
            );

            return ChartDialogBox(chartData: chartData);
          },
        );
      } else {
        context.showSnackBarError('Error while fetching the cash history');
      }
    },
  );
}
