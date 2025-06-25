import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/page/club_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'package:provider/provider.dart';

Widget getClubNameListTile(BuildContext context, Club club) {
  return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Icon(iconClub, color: Colors.green, size: iconSizeMedium),
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
    future: Club.fromId(
        idClub, Provider.of<UserSessionProvider>(context, listen: false).user),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          width: 60,
          child: Row(
            children: [
              Icon(iconClub),
              formSpacer6,
              Expanded(child: LinearProgressIndicator()),
            ],
          ),
        );
      } else if (snapshot.hasError) {
        return ErrorWithBackButton(errorMessage: snapshot.error.toString());
      } else if (snapshot.hasData && snapshot.data != null) {
        return getClubNameListTile(context, snapshot.data!);
      } else {
        return ErrorWithBackButton(errorMessage: 'No data available');
      }
    },
  );
}
