import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/multiverse/multiverseWidgets.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

Widget getClubCard(BuildContext context, Profile user, Club club, int index) {
  // Profile user = Provider.of<SessionProvider>(context, listen: false).user!;
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
          onTap: () {
            Provider.of<SessionProvider>(context, listen: false)
                .providerSetSelectedClub(club.id);
          },
          leading: CircleAvatar(
            backgroundColor: (club.id == user.selectedClub?.id)
                ? Colors.green
                : Colors.blueGrey,
            child: Text(
              (index + 1).toString(),
            ),
          ),
          shape: shapePersoRoundedBorder(
            isSelectedCLub ? colorIsSelected : Colors.blueGrey,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              club.getClubNameClickable(context),
              club.getLastResultsWidget(context),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              club.getRankingWidget(context),
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
                                      child: persoCancelRow,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: persoValidRow('Yes'),
                                      onPressed: () async {
                                        bool isOK = await operationInDB(
                                            context, 'UPDATE', 'profiles',
                                            data: {
                                              'id_default_club': club.id,
                                            },
                                            matchCriteria: {
                                              'uuid_user': user.id
                                            });

                                        if (isOK) {
                                          context.showSnackBar(
                                              'Successfully changed your default club to ${club.name}',
                                              icon: Icon(
                                                  iconSuccessfulOperation,
                                                  color: Colors.green));
                                        }
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
              const SizedBox(height: 6),
              club.getQuickAccessWidget(context, club.id),
              const SizedBox(height: 6),
            ],
          ),
      ],
    ),
  );
}
