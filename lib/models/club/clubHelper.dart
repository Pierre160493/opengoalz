import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
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
            '${clubPosition(club.clubData.posLeague)} of ${club.league!.name}'),
    subtitle: clubRankingPointsRow(context, club),
  );
}

Widget clubRankingPointsRow(BuildContext context, Club club) {
  return InkWell(
    onTap: () {
      ClubData.showClubHistoryDialog(
        context,
        club,
        'ranking_points',
        'Ranking Points',
        club.clubData.rankingPoints,
      );
    },
    child: Row(
      children: [
        Icon(
          iconRankingPoints,
          size: iconSizeSmall,
          color: Colors.green,
        ),
        Text(club.clubData.rankingPoints.toString() + ' Ranking Points'),
      ],
    ),
  );
}

String clubPosition(int position) {
  if (position == 1) {
    return '1st';
  } else if (position == 2) {
    return '2nd';
  } else if (position == 3) {
    return '3rd';
  } else {
    return position.toString() + 'th';
  }
}
