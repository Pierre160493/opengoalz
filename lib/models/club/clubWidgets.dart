import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';

Widget getClubCashListTile(Club club) {
  return ListTile(
    shape: shapePersoRoundedBorder,
    leading: Icon(iconCash,
        color: club.cash >= 0 ? Colors.green : Colors.red,
        size: iconSizeMedium),
    title: Text(
      NumberFormat.decimalPattern().format(club.cash).replaceAll(',', ' '),
      style: TextStyle(
          color: club.cash >= 0 ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold),
    ),
    subtitle: Text(
      'Club\'s Available Cash',
      style: styleItalicBlueGrey,
    ),
  );
}
