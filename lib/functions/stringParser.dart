import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/pages/country_page.dart';
import 'package:opengoalz/pages/game_page.dart';
import 'package:opengoalz/pages/league_page.dart';
import 'package:opengoalz/pages/teamCompPage.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

TextSpan stringParser(BuildContext context, String description,
    {Color colorDefaultText = Colors.white}) {
  final RegExp regex = RegExp(
      r'\{id(Player|Club|League|Game|Teamcomp|Country):(-?\d+),([^}]+)\}');
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
          switch (type) {
            case 'player':
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
            case 'club':
              Navigator.push(
                context,
                ClubPage.route(int.parse(id)),
              );
              break;
            case 'league':
              Navigator.push(
                context,
                LeaguePage.route(int.parse(id)),
              );
              break;
            case 'game':
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
            case 'teamcomp':
              Navigator.push(
                context,
                TeamCompPage.routeWithId(int.parse(id)),
              );
              break;
            case 'country':
              Navigator.push(
                context,
                CountryPage.route(int.parse(id), idMultiverse: null),
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
