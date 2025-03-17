import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/playerCoachScoutCoefListTile.dart';
import 'package:opengoalz/models/player/playerExpensesListTile.dart';
import 'package:opengoalz/models/player/playerSearchDialogBox.dart';
import 'package:opengoalz/models/player/playerWidgets.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/postgresql_requests.dart';
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
                onPressed: () async {
                  if (await context.showConfirmationDialog(
                          'Are you sure you want to recruit a new $title ?') ==
                      false) {
                    return;
                  }

                  // bool playerFromClub =
                  //     await context.showConfirmationDialogWith2Options(
                  //         'Do you wish to recruit a player from the team or from outise ?',
                  //         'From team',
                  //         'From outside');

                  Player? player;
                  // if (playerFromClub) {
                  player = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayersPage(
                        playerSearchCriterias:
                            PlayerSearchCriterias(idClub: [club.id]),
                        isReturningPlayer: true,
                      ),
                    ),
                  );
                  // } else {
                  //   showDialog<PlayerSearchCriterias>(
                  //     context: context,
                  //     builder: (BuildContext context) {
                  //       return playerSearchDialogBox(
                  //         inputPlayerSearchCriterias: PlayerSearchCriterias(),
                  //       );
                  //     },
                  //   ).then((playerSearchCriterias) async {
                  //     if (playerSearchCriterias != null) {
                  //       player = await Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => PlayersPage(
                  //             playerSearchCriterias: PlayerSearchCriterias(),
                  //             isReturningPlayer: true,
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //   });
                  // }

                  if (player == null) {
                    return;
                  }

                  bool isOK = await operationInDB(context, 'UPDATE', 'clubs',
                      data: {'id_${title.toLowerCase()}': player.id},
                      matchCriteria: {'id': club.id});

                  if (isOK) {
                    context.showSnackBar(
                        'Successfully hired ${player.getFullName()} as our new ${title.toLowerCase()}',
                        icon:
                            Icon(iconSuccessfulOperation, color: Colors.green));
                  }
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

              /// Fire coach
              trailing: IconButton(
                icon: Icon(iconLeaveClub, color: Colors.red),
                tooltip: 'Fire ${player.getFullName()}',
                iconSize: iconSizeMedium,
                onPressed: () async {
                  if (await context.showConfirmationDialog(
                      'Are you sure you want to fire ${player.getFullName()} as $title ?')) {
                    bool isOK = await operationInDB(context, 'UPDATE', 'clubs',
                        data: {'id_${title.toLowerCase()}': null},
                        matchCriteria: {'id': club.id});

                    if (isOK) {
                      context.showSnackBar(
                          'Successfully fired ${player.getPlayerNameString()}',
                          icon: Icon(iconSuccessfulOperation,
                              color: Colors.green));
                    }
                  }
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
