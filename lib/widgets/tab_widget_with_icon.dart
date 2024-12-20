import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

Widget buildTabWithIcon(IconData icon, String text) {
  return Tab(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: iconSizeSmall),
        formSpacer3,
        Text(text),
      ],
    ),
  );
}

Widget buildTabWithIcon2(BuildContext context, Row row) {
  return Tab(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        row,
      ],
    ),
  );
}
