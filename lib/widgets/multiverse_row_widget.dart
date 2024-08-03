import 'package:flutter/material.dart';

Widget multiverseWidget(int multiverseSpeed) {
  return InkWell(
      onTap: () {
        // print('Multiverse Speed: $multiverseSpeed');
      },
      child: Row(
        children: [
          Icon(Icons.speed),
          SizedBox(width: 3),
          Text('X '),
          Text(
            multiverseSpeed.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ));
}
