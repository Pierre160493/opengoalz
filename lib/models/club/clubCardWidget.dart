import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/multiverse/multiverseWidgets.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

Widget getClubCard(BuildContext context, Club club, int index) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24), // Adjust border radius as needed
      side: const BorderSide(
        color: Colors.blueGrey, // Border color
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
            backgroundColor: (club.id ==
                    Provider.of<SessionProvider>(context, listen: false)
                        .user!
                        .selectedClub
                        ?.id)
                ? Colors.green
                : Colors.blueGrey,
            child: Text(
              (index + 1).toString(),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24), // Adjust border radius as needed
            side: const BorderSide(
              color: Colors.blueGrey, // Border color
            ),
          ),
          hoverColor: Colors.brown,
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
        ),
        if (club.id ==
            Provider.of<SessionProvider>(context, listen: false)
                .user!
                .selectedClub
                ?.id)
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
