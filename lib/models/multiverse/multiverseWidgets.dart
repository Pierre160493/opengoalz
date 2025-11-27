import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/pages/multiverse_page.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'package:intl/intl.dart';

Color getMultiverseSyncColor(Multiverse multiverse) {
  if (multiverse.error != null) {
    return Colors.red;
  }
  if (multiverse.dateDelete != null) {
    return Colors.amber;
  }
  if (multiverse.dateHandling.isBefore(DateTime.now())) {
    return Colors.orange;
  }
  return Colors.green;
}

Widget getMultiverseIconFromMultiverse(Multiverse multiverse) {
  Color syncColor = getMultiverseSyncColor(multiverse);
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
            color: getMultiverseSyncColor(multiverse), size: iconSizeMedium),
        formSpacer3,
        Text('X '),
        Text(
          multiverse.speed.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
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
        return ErrorWithBackButton(errorMessage: snapshot.error.toString());
      } else if (snapshot.hasData && snapshot.data != null) {
        return getMultiverseIconFromMultiverse_Clickable(
            context, snapshot.data!); // Display the multiverse widget
      } else {
        return ErrorWithBackButton(errorMessage: 'No data available');
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
        return ErrorWithBackButton(errorMessage: snapshot.error.toString());
      } else if (snapshot.hasData && snapshot.data != null) {
        return getMultiverseListTileFromMultiverse(
            context, snapshot.data!); // Display the multiverse widget
      } else {
        return ErrorWithBackButton(errorMessage: 'No data available');
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

Widget multiverseSpeedTile(Multiverse multiverse) {
  Color syncColor = getMultiverseSyncColor(multiverse);

  return ListTile(
    leading: Icon(iconMultiverseSpeed, color: syncColor, size: iconSizeMedium),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          multiverse.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        getMultiverseSpeedRow(multiverse),
      ],
    ),
    subtitle: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.speed, color: Colors.green, size: iconSizeSmall),
            formSpacer3,
            Text(getMultiverseSpeedDescription(multiverse.speed),
                style: styleItalicBlueGrey),
          ],
        ),
        Row(
          children: [
            Icon(
              multiverse.dateDelete != null
                  ? Icons.delete_forever
                  : Icons.check_circle,
              color: syncColor,
              size: iconSizeSmall,
            ),
            SizedBox(width: 4),
            Text(
                multiverse.dateDelete != null
                    ? 'Deleting: ${formatDate(multiverse.dateDelete!)}'
                    : 'Active',
                style: styleItalicBlueGrey),
          ],
        ),
      ],
    ),
    shape: shapePersoRoundedBorder(),
  );
}

Widget multiverseSeasonTile(Multiverse multiverse) {
  return ListTile(
    leading:
        Icon(Icons.calendar_today, color: Colors.green, size: iconSizeMedium),
    title: Text('Currently playing season ${multiverse.seasonNumber}'),
    subtitle: Text('Week ${multiverse.weekNumber} Day ${multiverse.dayNumber}',
        style: styleItalicBlueGrey),
    shape: shapePersoRoundedBorder(),
  );
}

Widget multiverseDateRangeTile(Multiverse multiverse) {
  return ListTile(
    leading: Icon(Icons.date_range, color: Colors.green, size: iconSizeMedium),
    title: Text(
        'From ${DateFormat('E d MMM \'at\' HH\'h:\'mm').format(multiverse.dateSeasonStart)} to ${DateFormat('E d MMM \'at\' HH\'h:\'mm').format(multiverse.dateSeasonEnd)}'),
    subtitle: Text(
        multiverse.dateSeasonEnd.difference(DateTime.now()).inDays > 0
            ? 'Ends in ${multiverse.dateSeasonEnd.difference(DateTime.now()).inDays} day(s)'
            : 'Ends in ${multiverse.dateSeasonEnd.difference(DateTime.now()).inHours} hour(s)',
        style: styleItalicBlueGrey),
    shape: shapePersoRoundedBorder(),
  );
}

Widget multiverseCashTile(Multiverse multiverse) {
  return ListTile(
    leading: Icon(iconMoney, color: Colors.green, size: iconSizeMedium),
    title: Text(persoFormatCurrency(multiverse.cashPrinted)),
    subtitle: Text('Amount of fixed money circulating in the multiverse',
        style: styleItalicBlueGrey),
    shape: shapePersoRoundedBorder(),
  );
}
