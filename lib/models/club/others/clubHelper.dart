import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/stringFunctions.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/class/club_data.dart';
import 'package:opengoalz/models/league/page/league_page.dart';

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
      color: getClubColor(club),
    ), // Icon to indicate players
    title: club.league == null
        ? Text('League Not Found', style: TextStyle(fontSize: fontSizeMedium))
        : Text(
            '${positionWithIndex(club.clubData.posLeague)} of ${club.league!.name}',
            style: TextStyle(
                fontSize: fontSizeMedium, fontWeight: FontWeight.bold)),
    subtitle: clubEloRow(context, club.id, club.clubData.eloPoints),
  );
}

Widget clubEloRow(BuildContext context, int? idClub, int? eloValue) {
  if (idClub == null) return Container();
  return Tooltip(
    message: 'Elo Points',
    child: InkWell(
      onTap: () {
        ClubData.showClubDataHistoryChartDialog(
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
              style: TextStyle(
                  fontSize: fontSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
        ],
      ),
    ),
  );
}

Color getClubColor(Club club) {
  if (club.isCurrentlySelected) {
    return colorIsSelected;
  } else if (club.isBelongingToConnectedUser) {
    return colorIsMine;
  } else {
    return Colors.green;
  }
}
