import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/multiverse/multiverse_widget_extension.dart';

Widget getMultiverseWidget(BuildContext context, int idMultiverse) {
  return FutureBuilder<Multiverse?>(
    future: Future.delayed(Duration(seconds: 3),
        () => Multiverse.fromId(idMultiverse)), // Add a 3-second delay
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          width: 60,
          child: Row(
            children: [
              Icon(iconMultiverseSpeed),
              formSpacer6,
              Expanded(child: LinearProgressIndicator()),
            ],
          ),
        );
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData && snapshot.data != null) {
        return snapshot.data!
            .getWidget(context); // Display the multiverse widget
      } else {
        return Center(child: Text('No data available'));
      }
    },
  );
}
