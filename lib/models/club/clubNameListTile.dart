import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/pages/club_page.dart';

Widget getClubNameListTile(BuildContext context, Club club) {
  return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Icon(icon_club, color: Colors.green, size: iconSizeMedium),
      title: club.getClubName(context, isRightClub: false),
      onTap: () async {
        Navigator.push(
          context,
          ClubPage.route(club.id),
        );
      });
}

Widget getClubNameFromId(BuildContext context, int idClub) {
  return FutureBuilder<Club?>(
    future: Club.fromId(idClub), // Remove the 3-second delay
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          width: 60,
          child: Row(
            children: [
              Icon(icon_club),
              formSpacer6,
              Expanded(child: LinearProgressIndicator()),
            ],
          ),
        );
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData && snapshot.data != null) {
        return getClubNameListTile(context, snapshot.data!);
      } else {
        return Center(child: Text('No data available'));
      }
    },
  );
}
