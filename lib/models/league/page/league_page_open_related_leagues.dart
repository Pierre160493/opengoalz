import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/models/league/page/league_page.dart';
import 'package:opengoalz/extensionBuildContext.dart';

class LeagueOtherLeaguesSelectionWidget extends StatelessWidget {
  final League league;

  const LeagueOtherLeaguesSelectionWidget({Key? key, required this.league})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Upper League
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if (league.idUpperLeague != null) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaguePage(
                        idLeague: league.idUpperLeague!,
                      ),
                    ),
                  );
                } else {
                  context.showSnackBarError(
                      'No upper league for first division leagues');
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_circle_up,
                    size: iconSizeMedium,
                    color: league.idUpperLeague == null
                        ? Colors.blueGrey
                        : Colors.green,
                  ),
                  Text('Upper League',
                      style: TextStyle(fontSize: fontSizeMedium)),
                  Icon(
                    Icons.arrow_circle_up,
                    size: iconSizeMedium,
                    color: league.idUpperLeague == null
                        ? Colors.blueGrey
                        : Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),

        /// Opposite league button
        if (league.level != 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Opposite league button
              InkWell(
                onTap: () {
                  if (league.level > 1) {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaguePage(
                          idLeague: -league.id,
                        ),
                      ),
                    );
                  } else {
                    context.showSnackBarError(
                        'No opposite league for first division leagues');
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.compare_arrows,
                      size: iconSizeMedium,
                      color: league.level == 1 ? Colors.blueGrey : Colors.green,
                    ),
                    Text('Opposite',
                        style: TextStyle(fontSize: fontSizeMedium)),
                    Icon(
                      Icons.compare_arrows,
                      size: iconSizeMedium,
                      color: league.level == 1 ? Colors.blueGrey : Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),

        /// Lower Leagues
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () async {
                if (league.idLowerLeague != null) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaguePage(
                        idLeague: league.idLowerLeague!,
                      ),
                    ),
                  );
                } else {
                  context.showSnackBarError(
                      'No lower league for a last division league');
                }
              },
              child: Row(
                children: [
                  Text(
                    'Lower Left',
                    style: TextStyle(
                      fontSize: fontSizeMedium,
                      color: Colors.grey,
                    ),
                  ),
                  formSpacer3,
                  Icon(
                    Icons.arrow_circle_down,
                    size: iconSizeMedium,
                    color: league.idLowerLeague != null
                        ? Colors.green
                        : Colors.grey,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                if (league.idLowerLeague != null) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaguePage(
                        idLeague: -league.idLowerLeague!,
                      ),
                    ),
                  );
                } else {
                  context.showSnackBarError(
                      'No lower league for a last division league');
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_circle_down,
                    size: iconSizeMedium,
                    color: league.idLowerLeague != null
                        ? Colors.green
                        : Colors.grey,
                  ),
                  formSpacer3,
                  Text(
                    'Lower Right',
                    style: TextStyle(
                      fontSize: fontSizeMedium,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
