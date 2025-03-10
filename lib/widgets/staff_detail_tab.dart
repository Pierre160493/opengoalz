import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/playerCoachScoutCoefListTile.dart';
import 'package:opengoalz/models/player/playerExpensesListTile.dart';
import 'package:opengoalz/models/player/playerWidgets.dart';
import 'package:opengoalz/widgets/countryListTile.dart';

class StaffDetailTab extends StatelessWidget {
  final Club club;
  final String title;

  const StaffDetailTab({Key? key, required this.club, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerRoles = {
      'Coach': club.coach,
      'Scout': club.scout,
    };

    /// Check if there is a player assigned to the role
    if (playerRoles[title] == null) {
      /// Return a message if there is no player assigned to the role
      if (playerRoles.containsKey(title)) {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                // tooltip: 'Click to recruit a new $title',
                onPressed: () {
                  print('Recruit a new $title');
                },
                icon: Icon(iconScout,
                    color: Colors.red, size: iconSizeLarge * 2)),
            Text('$title not assigned, click to recruit a new one'),
          ],
        ));
      } else {
        /// Return a message if the role is not valid
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconError, color: Colors.red, size: iconSizeLarge * 2),
            Text('ERROR: $title is not a valid staff member'),
          ],
        ));
      }
    }
    Player player = playerRoles[title]!;

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
        child: Column(
          children: [
            /// Player List Tile
            ListTile(
              leading: CircleAvatar(child: Icon(player.getPlayerIcon())),
              shape: shapePersoRoundedBorder(),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      player.getPlayerNameClickable(context),
                      player.getStatusRow(),
                    ],
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getClubNameClickable(context, club, null),
                  playerSmallNotesIcon(context, player),
                ],
              ),
              trailing: IconButton(
                icon: Icon(iconLeaveClub, color: Colors.red),
                tooltip: 'Fire ${player.getFullName()}',
                iconSize: iconSizeMedium,
                onPressed: () {
                  print('Fire $title');
                },
              ),
            ),
            Divider(),
            Row(
              children: [
                Expanded(child: getAgeListTile(context, player)),
                Expanded(
                    child: getCountryListTileFromIdCountry(
                        context, player.idCountry, player.idMultiverse)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: getCoachScoutCoefWidget(context, player, title),
                ),
                Expanded(child: getExpensesWidget(context, player)),
              ],
            ),
            Divider(),
            ListTile(
              leading: Icon(iconCoach,
                  color: getColorBasedOnValue(player.coefCoach)),
              title: Text(player.coefCoach.toString()),
              subtitle: Text('Coach Coeffcient', style: styleItalicBlueGrey),
              shape: shapePersoRoundedBorder(),
            ),
            ListTile(
              leading: Icon(iconScout,
                  color: getColorBasedOnValue(player.coefScout)),
              title: Text(player.coefScout.toString()),
              subtitle: Text('Scout Coeffcient', style: styleItalicBlueGrey),
              shape: shapePersoRoundedBorder(),
            ),
          ],
        ),
      ),
    );
  }

  Color getColorBasedOnValue(int value) {
    if (value > 50) {
      return Colors.green;
    } else if (value > 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
