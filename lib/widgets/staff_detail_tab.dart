import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/playerExpensesListTile.dart';
import 'package:opengoalz/models/player/playerWidgets.dart';
import 'package:opengoalz/widgets/countryListTile.dart';

class StaffDetailTab extends StatelessWidget {
  final Player? player;
  final String title;

  const StaffDetailTab({Key? key, required this.player, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (player == null) {
      return Center(child: Text('$title not assigned'));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Column(
          children: [
            /// Player List Tile
            ListTile(
              leading: CircleAvatar(child: Icon(player!.getPlayerIcon())),
              shape: shapePersoRoundedBorder(),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      player!.getPlayerNameToolTip(context),
                      player!.getStatusRow(),
                    ],
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getClubNameClickable(context, player!.club, player!.idClub),
                  Row(
                    children: [
                      playerSmallNotesIcon(context, player!),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Row(
              children: [
                Expanded(child: getAgeListTile(context, player!)),
                Expanded(
                    child: getCountryListTileFromIdCountry(
                        context, player!.idCountry, player!.idMultiverse)),
              ],
            ),
            Row(
              children: [
                // Expanded(child: getPerformanceScoreListTile(context)),
                Expanded(child: getExpensesWidget(context, player!)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
