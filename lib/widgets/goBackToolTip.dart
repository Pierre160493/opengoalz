import 'package:flutter/material.dart';

Widget goBackIconButton(BuildContext context) {
  return IconButton(
    tooltip: 'Go back',
    icon: Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}
