import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/widgets/overflow_tooltip_text.dart';

/// Old version without overflow handling
Widget buildTabWithIconOld({
  required String text,
  Color iconColor = Colors.green,
  IconData? icon,
}) {
  return Tab(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor, size: iconSizeMedium),
          formSpacer3,
        ],
        Text(text, style: TextStyle(fontSize: fontSizeMedium)),
      ],
    ),
  );
}

Widget buildTabWithIcon({
  required String text,
  Color iconColor = Colors.green,
  IconData? icon,
}) {
  return Tab(
    child: OverflowTooltipText(
      text: text,
      style: TextStyle(fontSize: fontSizeMedium),
      leading: icon != null
          ? Icon(icon, color: iconColor, size: iconSizeMedium)
          : null,
      leadingWidth: icon != null ? iconSizeMedium : null,
      leadingSpacing: 3.0, // Match formSpacer3
    ),
  );
}
