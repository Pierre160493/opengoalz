import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

Widget buildTabWithIcon({
  required String text,
  Color iconColor = Colors.green,
  IconData? icon,
}) {
  return Tab(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor),
          formSpacer3,
        ],
        Text(text),
      ],
    ),
  );
}
