import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

DateTime calculateDateBirth(double age, int multiverseSpeed) {
  return DateTime.now().subtract(Duration(
    seconds: (age * 14 * 7 * 24 * 3600 / multiverseSpeed).round(),
  ));
}

double calculateAge(DateTime dateBirth, int multiverseSpeed,
    {DateTime? dateEnd}) {
  dateEnd ??= DateTime.now();
  return dateEnd.difference(dateBirth).inSeconds /
      (14 * 7 * 24 * 3600 / multiverseSpeed);
}

String getAgeString(double age) {
  return '${age.truncate()} & ${(age % 1 * 14 * 7).floor()} days';
}

Widget getAgeStringRow(double age) {
  final style = TextStyle(fontSize: fontSizeMedium);
  final boldStyle = style.copyWith(fontWeight: FontWeight.bold);
  return Row(children: [
    Text(age.truncate().toString(), style: boldStyle),
    Text(' & ', style: style),
    Text(((age % 1) * 14 * 7).floor().toString(), style: boldStyle),
    Text(' days', style: style),
  ]);
}
