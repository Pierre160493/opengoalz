import 'package:flutter/material.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/pages/multiverse_page.dart';
import 'package:opengoalz/constants.dart';

extension MultiverseWidgetExtension on Multiverse {
  Widget getWidget() {
    return Tooltip(
      message: 'Multiverse Speed',
      child: Row(
        children: [
          Icon(iconMultiverseSpeed),
          formSpacer3,
          Text('X '),
          Text(
            speed.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget getWidgetClickable(BuildContext context) {
    return Tooltip(
      message: 'Multiverse Speed',
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiversePage(id: id),
            ),
          );
        },
        child: Row(
          children: [
            Icon(iconMultiverseSpeed),
            formSpacer3,
            Text('X '),
            Text(
              speed.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
