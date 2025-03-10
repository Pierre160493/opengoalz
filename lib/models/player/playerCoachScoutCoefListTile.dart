import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerWidgets.dart';

Widget getCoachScoutCoefWidget(
    BuildContext context, Player player, String title) {
  IconData icon;
  int value;
  if (title == 'Coach') {
    icon = iconCoach;
    value = player.coefCoach;
  } else if (title == 'Scout') {
    icon = iconScout;
    value = player.coefScout;
  } else {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(iconError, color: Colors.red, size: iconSizeLarge * 2),
        Text('ERROR: $title is not a valid staff member'),
      ],
    ));
  }
  return ListTile(
    shape: shapePersoRoundedBorder(),
    leading: Icon(
      icon,
      color: Colors.green,
      size: iconSizeMedium, // Adjust icon size as needed
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    subtitle: Text(
      '$title coefficient',
      style: styleItalicBlueGrey,
    ),
    onTap: () => showDialog(
      context: context,
      builder: (BuildContext context) {
        return getPlayerHistoryStreamGraph(
            context,
            player.id,
            [title == '' ? 'coef_coach' : 'coef_scout'],
            '${title} coefficient');
      },
    ),
  );
}
