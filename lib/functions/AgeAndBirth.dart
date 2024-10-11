import 'package:flutter/material.dart';

DateTime calculateDateBirth(double age, int multiverseSpeed) {
  return DateTime.now().subtract(Duration(
    seconds: (age * 14 * 7 * 24 * 3600 / multiverseSpeed).round(),
  ));
}

double calculateAge(DateTime dateBirth, int multiverseSpeed) {
  return DateTime.now().difference(dateBirth).inSeconds /
      (14 * 7 * 24 * 3600 / multiverseSpeed);
}

Widget getAgeStringRow(double age, int multiverseSpeed) {
  return Row(children: [
    Text(
      age.truncate().toString(),
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(
      ' & ',
    ),
    Text(
      // ((age - age.truncate()) * 14 * 7 / multiverseSpeed).floor().toString(),
      ((age % 1) * 14 * 7).floor().toString(),
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(
      ' days',
    ),
  ]);
}

// DateTime calculateDateBirth2(double age, int multiverseSpeed) {
//   return DateTime.now().subtract(Duration(
//     days: (age * 14 * 7 / multiverseSpeed).round(),
//   ));
// }
