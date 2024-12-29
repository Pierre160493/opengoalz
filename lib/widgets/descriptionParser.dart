import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/pages/league_page.dart';

TextSpan parseDescriptionTextSpan(BuildContext context, String description) {
  final RegExp regex = RegExp(r'\{id(Player|Club|League):(\d+),([^}]+)\}');
  final List<TextSpan> spans = [];
  int start = 0;

  for (final match in regex.allMatches(description)) {
    if (match.start > start) {
      spans.add(TextSpan(text: description.substring(start, match.start)));
    }
    final String type = match.group(1)!.toLowerCase();
    final String id = match.group(2)!;
    final String text = match.group(3)!;

    print('type: $type, id: $id, text: $text');

    spans.add(TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          if (type == 'player') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayersPage(
                  playerSearchCriterias:
                      PlayerSearchCriterias(idPlayer: [int.parse(id)]),
                ),
              ),
            );
          } else if (type == 'club') {
            Navigator.push(
              context,
              ClubPage.route(int.parse(id)),
            );
          } else if (type == 'league') {
            Navigator.push(
              context,
              LeaguePage.route(int.parse(id)),
            );
          }
        },
    ));
    start = match.end;
  }

  if (start < description.length) {
    spans.add(TextSpan(text: description.substring(start)));
  }

  return TextSpan(children: spans);
}
