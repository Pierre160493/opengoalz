import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/pages/multiverse_page.dart';

Color getMultiverseSyncColor(DateTime lastRun) {
  int minutesSinceLastRun = DateTime.now().difference(lastRun).inMinutes;

  if (minutesSinceLastRun >= 2) {
    return Colors.red;
    // } else if (minutesSinceLastRun >= 1) {
    //   return Colors.orange;
  } else {
    return Colors.green;
  }
}

Widget getMultiverseIconFromMultiverse(Multiverse multiverse) {
  Color syncColor = getMultiverseSyncColor(multiverse.lastRun);
  return Row(
    children: [
      if (syncColor != Colors.green)
        Tooltip(
          message: 'Last run: ' + formatDate(multiverse.lastRun),
          child: Icon(
            Icons.sync_problem,
            color: syncColor,
          ),
        ),
      getMultiverseSpeedRow(multiverse),
    ],
  );
}

Widget getMultiverseSpeedRow(Multiverse multiverse) {
  return Tooltip(
    message:
        'Multiverse Speed: ' + getMultiverseSpeedDescription(multiverse.speed),
    child: Row(
      children: [
        Icon(iconMultiverseSpeed,
            color: multiverse.isActive ? Colors.green : Colors.red),
        formSpacer3,
        Text('X '),
        Text(
          multiverse.speed.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget getMultiverseIconFromId_Clickable(
    BuildContext context, int idMultiverse) {
  return FutureBuilder<Multiverse?>(
    future: Multiverse.fromId(idMultiverse), // Remove the 3-second delay
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          width: 60,
          child: Row(
            children: [
              Icon(iconMultiverseSpeed),
              formSpacer6,
              Expanded(child: LinearProgressIndicator()),
            ],
          ),
        );
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData && snapshot.data != null) {
        return getMultiverseIconFromMultiverse_Clickable(
            context, snapshot.data!); // Display the multiverse widget
      } else {
        return Center(child: Text('No data available'));
      }
    },
  );
}

Widget getMultiverseIconFromMultiverse_Clickable(
    BuildContext context, Multiverse multiverse) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiversePage(idMultiverse: multiverse.id),
        ),
      );
    },
    child: getMultiverseIconFromMultiverse(multiverse),
  );
}

Widget getMultiverseIconFromMultiverse_Tooltip(Multiverse multiverse) {
  return Tooltip(
    message: 'Multiverse Speed',
    child: getMultiverseIconFromMultiverse(multiverse),
  );
}

Widget getMultiverseListTileFromMultiverse(
    BuildContext context, Multiverse multiverse) {
  return ListTile(
    shape: shapePersoRoundedBorder(),
    leading: Icon(
      iconMultiverseSpeed,
      size: iconSizeMedium,
      color: Colors.green,
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Multiverse: ${multiverse.name}'),
        getMultiverseIconFromMultiverse(multiverse),
      ],
    ),
    subtitle: Text(getMultiverseSpeedDescription(multiverse.speed),
        style: styleItalicBlueGrey),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiversePage(idMultiverse: multiverse.id),
        ),
      );
    },
  );
}

Widget getMultiverseListTileFromId(BuildContext context, int idMultiverse) {
  return FutureBuilder<Multiverse?>(
    future: Multiverse.fromId(idMultiverse), // Remove the 3-second delay
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return loadingCircularAndText('Loading Multiverse...');
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData && snapshot.data != null) {
        return getMultiverseListTileFromMultiverse(
            context, snapshot.data!); // Display the multiverse widget
      } else {
        return Center(child: Text('No data available'));
      }
    },
  );
}

String getMultiverseSpeedDescription(int speed) {
  if (speed <= 7)
    return '$speed games per week';
  else if (speed < 7 * 24)
    return '${speed / 7} games per day';
  else
    return '${speed / (7 * 24)} games per hour';
}

Widget getMultiverseSelectionListTile(
    BuildContext context, Multiverse? multiverse) {
  return ListTile(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
      side: BorderSide(
          color: multiverse == null ? Colors.red : Colors.green, width: 2.0),
    ),
    title: ElevatedButton(
      onPressed: () async {
        multiverse = await Navigator.push<Multiverse>(
          context,
          MultiversePage.route(
            1,
            isReturningMultiverse: true,
          ),
        );
      },
      child: multiverse == null
          ? Row(
              children: [
                Icon(iconError, color: Colors.red),
                formSpacer6,
                Text('Select Multiverse'),
              ],
            )
          : Row(
              children: [
                Icon(iconSuccessfulOperation, color: Colors.green),
                formSpacer6,
                Text('Multiverse: ${multiverse.name}'),
              ],
            ),
    ),
    trailing: multiverse == null
        ? null
        : IconButton(
            tooltip: 'Reset the selected multiverse',
            onPressed: () {
              multiverse = null;
            },
            icon: Icon(Icons.delete_forever, color: Colors.red),
          ),
  );
}
