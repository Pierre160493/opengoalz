import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/clubCardWidget.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/widgets/clubAndPlayerCreationDialogBox.dart';

Widget userClubListWidget(BuildContext context, Profile user) {
  return Column(
    children: [
      formSpacer6,
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.list, color: Colors.green),
          SizedBox(width: 8),
          Text(
            'Here is the list of your clubs:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      formSpacer6,
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: user.clubs.length,
          itemBuilder: (context, index) {
            final Club club = user.clubs[index];
            return getClubCard(context, user, club, index);
          },
        ),
      ),
      if (user.numberClubsAvailable > user.clubs.length)
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24), // Adjust border radius as needed
            side: const BorderSide(
              color: Colors.blueGrey, // Border color
            ),
          ),
          leading: const Icon(Icons.add_home_work, color: Colors.green),
          title: Text(user.clubs.length == 0
              ? 'You dont have any club yet'
              : 'Get an additional club'),
          subtitle: Text(
              user.clubs.length == 0
                  ? 'Create a club to start your aventure and show your skills !'
                  : 'Get an additional club to show your skills',
              style: TextStyle(
                  color: Colors.blueGrey, fontStyle: FontStyle.italic)),
          onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return AssignPlayerOrClubDialog(isClub: true);
            },
          ),
        ),
    ],
  );
}
