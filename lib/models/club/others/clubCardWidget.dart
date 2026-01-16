import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/class/club_widgets.dart';
import 'package:opengoalz/models/multiverse/multiverseWidgets.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

Widget getClubCard(BuildContext context, Profile user, Club club, int index) {
  bool isSelectedCLub = club.id == user.selectedClub?.id;
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Adjust border radius as needed
      side: BorderSide(
        color:
            isSelectedCLub ? colorIsSelected : Colors.blueGrey, // Border color
        width: 3.0,
      ),
    ),
    child: Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6.0),
          minLeadingWidth: 0,
          onTap: () {
            Provider.of<UserSessionProvider>(context, listen: false)
                // .providerSetSelectedClub(club.id);
                .providerFetchUser(context,
                    userId: supabase.auth.currentUser!.id,
                    selectedIdClub: club.id);
          },
          leading: CircleAvatar(
            radius: iconSizeSmall,
            backgroundColor: (club.id == user.selectedClub?.id)
                ? Colors.green
                : Colors.blueGrey,
            child: Text(
              (index + 1).toString(),
              style: TextStyle(
                  fontSize: fontSizeMedium, fontWeight: FontWeight.bold),
            ),
          ),
          shape: shapePersoRoundedBorder(
            isSelectedCLub ? colorIsSelected : Colors.blueGrey,
          ),
          title: Row(
            children: [
              Expanded(child: getClubNameClickable(context, club)),
              formSpacer6,
              getLastResultsWidget(context, club),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(child: getClubRankingRow(context, club)),
              const SizedBox(width: 8),
              getMultiverseIconFromId_Clickable(context, club.idMultiverse),
            ],
          ),
          trailing:

              /// If the club is the selected club and not the default club, show a star
              (club.id == user.selectedClub?.id &&
                      club.id != user.idDefaultClub)
                  ? IconButton(
                      tooltip: 'Set as default club',
                      icon: Icon(Icons.star),
                      color: Colors.yellow,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Set Default Club'),
                              content: Text(
                                  'Are you sure you want to set ${club.name} as your default club?'),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      child: persoCancelRow(),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: persoValidRow('Yes'),
                                      onPressed: () async {
                                        await operationInDB(
                                            context, 'UPDATE', 'profiles',
                                            data: {
                                              'id_default_club': club.id,
                                            },
                                            matchCriteria: {
                                              'uuid_user': user.id
                                            },
                                            messageSuccess:
                                                'Successfully changed your default club to ${club.name}');

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      })
                  : null,
        ),
        if (club.id == user.selectedClub?.id)
          Column(
            children: [
              formSpacer6,
              getQuickAccessWidget(context, club, user),
              formSpacer6,
            ],
          ),
      ],
    ),
  );
}
