import 'package:flutter/material.dart';

Widget buildTab(IconData icon, String text) {
  return Tab(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        SizedBox(width: 3), // Add some spacing between the icon and text
        Text(text),
      ],
    ),
  );
}
