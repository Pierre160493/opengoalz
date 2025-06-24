import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/club/page/club_page.dart';
import 'package:opengoalz/pages/country_page.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/models/league/page/league_page.dart';
import 'package:opengoalz/pages/teamCompPage.dart';
import 'package:opengoalz/pages/user_page/user_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

TextSpan stringParser(BuildContext context, String description,
    {Color colorDefaultText = Colors.white}) {
  final RegExp regex = RegExp(
      r'\{(idPlayer|idClub|idLeague|idGame|idTeamcomp|idCountry|uuidUser):([a-fA-F0-9\-]+),([^}]+)\}');
  final List<TextSpan> spans = [];
  int start = 0;

  for (final match in regex.allMatches(description)) {
    if (match.start > start) {
      spans.add(TextSpan(
        text: description.substring(start, match.start),
        style: TextStyle(color: colorDefaultText),
      ));
    }
    final String type = match.group(1)!.toLowerCase();
    final String id = match.group(2)!;
    final String text = match.group(3)!;

    spans.add(TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          print('Tapped on $type with id $id and text "$text"');
          switch (type) {
            case 'idplayer':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayersPage(
                    playerSearchCriterias:
                        PlayerSearchCriterias(idPlayer: [int.parse(id)]),
                  ),
                ),
              );
              break;
            case 'idclub':
              Navigator.push(
                context,
                ClubPage.route(int.parse(id)),
              );
              break;
            case 'idleague':
              Navigator.push(
                context,
                LeaguePage.route(int.parse(id)),
              );
              break;
            case 'idgame':
              Navigator.push(
                context,
                GamePage.route(
                    int.parse(id),
                    Provider.of<UserSessionProvider>(context, listen: false)
                        .user
                        .selectedClub!
                        .id),
              );
              break;
            case 'idteamcomp':
              Navigator.push(
                context,
                TeamCompPage.routeWithId(int.parse(id)),
              );
              break;
            case 'idcountry':
              Navigator.push(
                context,
                CountryPage.route(int.parse(id), idMultiverse: null),
              );
              break;
            case 'uuiduser':
              Navigator.push(
                context,
                UserPage.route(uuidUser: id),
              );
              break;
          }
        },
    ));
    start = match.end;
  }

  if (start < description.length) {
    spans.add(TextSpan(
      text: description.substring(start),
      style: TextStyle(color: colorDefaultText),
    ));
  }

  return TextSpan(children: spans);
}
