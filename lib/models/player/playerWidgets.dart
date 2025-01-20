import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions/AgeAndBirth.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerHistoryListTiles.dart';
import 'package:opengoalz/models/player/playerNotesDialogBox.dart';
import 'package:opengoalz/models/player/playerShirtNumberDialogBox.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:provider/provider.dart';

Widget playerShirtNumberIcon(BuildContext context, Player player) {
  bool isPlayerClubSelected =
      Provider.of<SessionProvider>(context, listen: false)
              .user!
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

Widget getPlayerHistoryStreamGraph(
    BuildContext context, int id, String field, String title) {
  Stream<List<Map>> _historyStream = supabase
      .from('players_history_stats')
      .stream(primaryKey: ['id'])
      .eq('id_player', id)
      .order('created_at', ascending: true)
      .map((maps) => maps
          .map((map) => {
                'created_at': map['created_at'],
                field: map[field],
              })
          .toList());

  return StreamBuilder<List<Map>>(
    stream: _historyStream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (!snapshot.hasData) {
        return Text('Error: No data');
      }
      final historyData = snapshot.data!;

      final chartData = ChartData(
        title: title,
        // xValues: historyData
        //     .map((item) => DateTime.parse(item['created_at'])
        //         .millisecondsSinceEpoch
        //         .toDouble())
        //     .toList(),
        yValues: [
          historyData.map((item) => (item[field] as num).toDouble()).toList()
        ],
        typeXAxis: XAxisType.weekHistory,
      );

      return ChartDialogBox(chartData: chartData);
    },
  );
}

Widget getAgeListTile(BuildContext context, Player player) {
  return ListTile(
    shape: shapePersoRoundedBorder(),
    leading: Icon(
      Icons.cake_outlined,
      size: iconSizeLarge,
      color: Colors.green,
    ),
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
            style:
                TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey)),
      ],
    ),
    onTap: () {
      /// Open a dialog box with the player's history
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth * 0.8, // Define a maximum width
              ),
              child: PlayerHistoryListTiles(player: player),
            ),
          );
        },
      );
    },
  );
}

Widget playerSetAsFavoriteIconButton(
    BuildContext context, Player player, Profile user) {
  int? promisedExpenses;
  if (player.isFavorite == null) {
    return Icon(iconFavorite, color: Colors.orange);
  }
  return IconButton(
    tooltip: 'Set as Favorite',
    icon: Icon(iconFavorite,
        color: player.isFavorite! ? Colors.red : Colors.blueGrey),
    iconSize: iconSizeSmall,
    onPressed: () async {
      if (player.idClub != null && player.idClub != user.selectedClub!.id) {
        /// Show dialog box asking if the user wants to set a promised expenses
        promisedExpenses = await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            int? promisedExpenses;
            return AlertDialog(
              title: Text('Set Promised Expenses'),
              content: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter promised expenses',
                ),
                onChanged: (value) {
                  promisedExpenses = int.tryParse(value);
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(promisedExpenses);
                  },
                ),
              ],
            );
          },
        );
        await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            int? promisedExpenses;
            return AlertDialog(
              title: Text('Set Promised Expenses'),
              content: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter promised expenses',
                ),
                onChanged: (value) {
                  promisedExpenses = int.tryParse(value);
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(promisedExpenses);
                  },
                ),
              ],
            );
          },
        );
      }
      bool isOK =
          await operationInDB(context, 'INSERT', 'players_favorite', data: {
        'id_club': user.selectedClub!.id,
        'id_player': player.id,
        'promised_expenses': promisedExpenses,
      });
      if (isOK) {
        context.showSnackBar(
            'Successfully set ${player.getFullName()} in the list of favorite players',
            icon: Icon(iconSuccessfulOperation, color: Colors.green));
      }
    },
  );
}
