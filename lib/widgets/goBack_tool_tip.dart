import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

Widget goBackIconButton(BuildContext context) {
  return IconButton(
    tooltip: 'Go back',
    icon: Icon(Icons.arrow_back, size: iconSizeLarge, color: Colors.green),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}
