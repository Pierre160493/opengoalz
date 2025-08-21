import 'package:flutter/material.dart';

Widget ErrorTextWidget(String text) {
  return Row(
    children: [
      Icon(Icons.error),
      SizedBox(width: 3.0),
      Text(text),
    ],
  );
}
