import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/stringFunctions.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/class/club_data.dart';
import 'package:opengoalz/pages/league_page.dart';

Widget clubLeagueAndRankingListTile(BuildContext context, Club club) {
  return ListTile(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LeaguePage(
            idLeague: club.idLeague,
          ),
        ),
      );
    },
    shape: shapePersoRoundedBorder(),
    leading: Icon(
      iconLeague,
      size: iconSizeMedium,
      color: Colors.green,
    ), // Icon to indicate players
    title: club.league == null
        ? Text('League Not Found')
        : Text(
            '${positionWithIndex(club.clubData.posLeague)} of ${club.league!.name}'),
    subtitle: clubEloRow(context, club.id, club.clubData.eloPoints),
  );
}

Widget clubEloRow(BuildContext context, int? idClub, int? eloValue) {
  if (idClub == null) return Container();
  return InkWell(
    onTap: () {
      ClubData.showClubHistoryChartDialog(
          context, idClub, 'elo_points', 'Elo Points Evolution');
    },
    child: Row(
      children: [
        Icon(
          iconRankingPoints,
          size: iconSizeSmall,
          color: Colors.green,
        ),
        Text(eloValue.toString(),
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      ],
    ),
  );
}
