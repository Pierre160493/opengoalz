import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

Widget buildTabWithIcon({
  required String text,
  Color color = Colors.green,
  IconData? icon,
}) {
  return Tab(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color),
          formSpacer3,
        ],
        Text(text),
      ],
    ),
  );
}
