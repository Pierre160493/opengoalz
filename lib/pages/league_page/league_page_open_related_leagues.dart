import 'package:flutter/material.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/pages/league_page/league_page.dart';
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
                    color: league.idUpperLeague == null
                        ? Colors.blueGrey
                        : Colors.green,
                  ),
                  const Text('Upper League'),
                  Icon(
                    Icons.arrow_circle_up,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      color: league.level == 1 ? Colors.blueGrey : Colors.green,
                    ),
                    const Text('Opposite'),
                    Icon(
                      Icons.compare_arrows,
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
                  const Text(
                    'Lower Left',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_circle_down,
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
                    color: league.idLowerLeague != null
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Lower Right',
                    style: TextStyle(
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
