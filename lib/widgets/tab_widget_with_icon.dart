import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

Widget buildTabWithIcon(IconData icon, String text) {
  return Tab(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: iconSizeSmall),
        SizedBox(width: 3), // Add some spacing between the icon and text
        Text(text),
      ],
    ),
  );
}
