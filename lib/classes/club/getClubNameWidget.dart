import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/constants.dart';

Widget getClubNameClickable(BuildContext context, Club? club, int? idCLub) {
  /// Returns a clickable widget with the club name
  if (club != null) {
    return club.getClubNameClickable(context);
  } else if (idCLub != null) {
    if (idCLub == 0) {
      return Row(
        children: [
          Icon(icon_club),
          Text(' No Club'),
        ],
      );
    }
    return StreamBuilder<Club>(
      stream: supabase
          .from('clubs')
          .stream(primaryKey: ['id'])
          .eq('id', idCLub)
          .map((maps) => maps.map((map) => Club.fromMap(map)).first),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('ERROR: ${snapshot.error}');
        } else {
          final Club club = snapshot.data!;
          return club.getClubNameClickable(context);
        }
      },
    );
  }
  return Row(
    children: [
      Icon(icon_club),
      Text(' No Club'),
    ],
  );
}
