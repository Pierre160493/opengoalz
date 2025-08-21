import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/others/getClubNameWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/pages/players_page.dart';
import 'package:opengoalz/models/player/widgets/tiles/player_expenses_tile.dart';
import 'package:opengoalz/models/player/widgets/tiles/player_staff_coef_tile.dart';
import 'package:opengoalz/models/player/widgets/tiles/player_age_tile.dart';
import 'package:opengoalz/models/player/widgets/player_icon.dart';
import 'package:opengoalz/models/player/widgets/player_small_notes_icon.dart';
import 'package:opengoalz/models/player/widgets/player_widgets.dart';
import 'package:opengoalz/models/player/widgets/player_status_row.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/widgets/country_tile.dart';

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
                  Player? player;
                  player = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayersPage(
                        playerSearchCriterias: PlayerSearchCriterias(
                            idClub: [club.id], retired: true),
                        isReturningPlayer: true,
                      ),
                    ),
                  );

                  if (player == null) {
                    return;
                  }

                  if (await context.showConfirmationDialog(
                          'Are you sure you want to recruit ${player.getFullName()} as your new $title ?\nThis will cost 1 000 !') ==
                      false) {
                    return;
                  }

                  await operationInDB(context, 'UPDATE', 'clubs',
                      data: {'id_${title.toLowerCase()}': player.id},
                      matchCriteria: {'id': club.id},
                      messageSuccess:
                          'Successfully hired ${player.getFullName()} as our new $title');
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
              leading: CircleAvatar(child: PlayerIcon(player: player)),
              shape: shapePersoRoundedBorder(),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      player.getPlayerNameClickable(context),
                      PlayerStatusRow(player: player),
                    ],
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getClubNameClickable(context, club, null),
                  PlayerSmallNotesIcon(player: player),
                ],
              ),

              /// Fire coach
              trailing: IconButton(
                icon: Icon(iconLeaveClub, color: Colors.red),
                tooltip: 'Fire ${player.getFullName()}',
                iconSize: iconSizeMedium,
                onPressed: () async {
                  if (await context.showConfirmationDialog(
                      'Are you sure you want to fire ${player.getFullName()} as $title ?\nThis will cost 1 000 !')) {
                    await operationInDB(context, 'UPDATE', 'clubs',
                        data: {'id_${title.toLowerCase()}': null},
                        matchCriteria: {'id': club.id},
                        messageSuccess:
                            'Successfully fired ${player.getPlayerNameString()}');
                  }
                },
              ),
            ),
            Divider(),
            Row(
              children: [
                Expanded(child: PlayerAgeTile(player: player)),
                Expanded(
                  child: CountryTileFromId(
                    idCountry: player.idCountry,
                    idMultiverse: player.idMultiverse,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: PlayerStaffCoefTile(player: player, title: title),
                ),
                Expanded(
                    child: PlayerExpensesTile(
                  player: player,
                )),
              ],
            ),
            Divider(),
            PlayerStaffCoefTile(player: player, title: 'Coach'),
            PlayerStaffCoefTile(player: player, title: 'Scout'),
          ],
        ),
      ),
    );
  }
}
