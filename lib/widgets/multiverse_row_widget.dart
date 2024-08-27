import 'package:flutter/material.dart';
import 'package:opengoalz/pages/multiverse_page.dart';

Widget multiverseWidget(BuildContext context, int multiverseSpeed) {
  return Tooltip(
    message: 'Multiverse Speed',
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
    ),
  );
}

Widget multiverseWidgetClickable(BuildContext context, int multiverseSpeed) {
  return Tooltip(
    message: 'Multiverse Speed',
    child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiversePage(speed: multiverseSpeed),
            ),
          );
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
        )),
  );
}
