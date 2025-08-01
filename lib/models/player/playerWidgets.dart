import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/AgeAndBirth.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerNotesDialogBox.dart';
import 'package:opengoalz/models/player/playerShirtNumberDialogBox.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:opengoalz/widgets/playerHistoryPage.dart';
import 'package:provider/provider.dart';

Widget playerShirtNumberIcon(BuildContext context, Player player) {
  bool isPlayerClubSelected =
      Provider.of<UserSessionProvider>(context, listen: false)
              .user
              .selectedClub!
              .id ==
          player.idClub;
  return InkWell(
    onTap: () {
      if (isPlayerClubSelected)
        // Open the shirt number dialog box
        showDialog(
          context: context,
          builder: (context) {
            return PlayerShirtNumberDialogBox(player: player);
          },
        );
    },
    child: Tooltip(
      message:
          'Shirt number: ${player.shirtNumber == null ? 'None' : player.shirtNumber}',
      child: Row(
        children: [
          Icon(
            iconShirt,
            color: player.shirtNumber == null ? Colors.red : Colors.green,
          ),
          if (player.shirtNumber != null)
            Text(
              player.shirtNumber.toString(),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    ),
  );
}

Widget playerSmallNotesIcon(BuildContext context, Player player) {
  return InkWell(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) {
          return PlayerNotesDialogBox(player: player);
        },
      );
    },
    child: Tooltip(
      message: 'Notes: ${player.notes}',
      child: Row(
        children: [
          Icon(
            iconNotesSmall,
            color: Colors.green,
          ),
          Text(
            player.notesSmall.toString(),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget getPlayerHistoryGraph(
    BuildContext context, int id, List<String> fieldsToPlot, String title) {
  return FutureBuilder<List<Map>>(
    future: supabase
        .from('players_history_stats')
        .select('created_at, ${fieldsToPlot.join(", ")}')
        .eq('id_player', id)
        .order('created_at', ascending: true)
        .then((response) => response),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return loadingCircularAndText('Loading player history...');
      } else if (snapshot.hasError) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
            'Failed to load player history: ${snapshot.error}',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
            'No data available for player history.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      }

      final historyData = snapshot.data!;

      // Check for null values in the required fields
      for (var field in fieldsToPlot) {
        if (historyData.any((item) => item[field] == null)) {
          return AlertDialog(
            title: Text('Data Error'),
            content: Text(
              'Error: Missing data for field "$field".',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        }
      }

      final chartData = ChartData(
        title: title,
        yValues: fieldsToPlot.map((field) {
          return historyData
              .map((item) => (item[field] as num).toDouble())
              .toList();
        }).toList(),
        typeXAxis: XAxisType.weekHistory,
      );

      return ChartDialogBox(chartData: chartData);
    },
  );
}

Widget getAgeListTile(BuildContext context, Player player) {
  return Tooltip(
    message: 'Click to see player history',
    waitDuration: const Duration(milliseconds: 500),
    child: ListTile(
      shape: shapePersoRoundedBorder(),
      leading: player.dateDeath != null
          ? Icon(
              iconDead,
              size: iconSizeLarge,
              color: Colors.red,
            )
          : Icon(Icons.cake_outlined, size: iconSizeLarge, color: Colors.green),
      title: Row(
        children: [
          getAgeStringRow(player.age),
        ],
      ),
      subtitle: Row(
        children: [
          Icon(Icons.event, size: iconSizeSmall, color: Colors.green),
          formSpacer3,
          Text(DateFormat(persoDateFormat).format(player.dateBirth),
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.blueGrey)),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerHistoryPage(player: player),
          ),
        );
      },
    ),
  );
}
