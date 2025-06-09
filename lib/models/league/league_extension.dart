part of 'league.dart';

extension LeagueWidgetHelper on League {
  /// Clickable widget of the league name
  Widget getLeagueNameClickable(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
            onTap: () {
              Navigator.push(
                context,
                LeaguePage.route(id),
              );
            },
            child: Text(name)),
      ],
    );
  }

  String getLeagueDescription() {
    /// International leagues
    if (level == 0) {
      if (number == 1) {
        return 'First international league';
      } else if (number == 2) {
        return 'Second international league';
      } else if (number == 3) {
        return 'Third international league';
      } else {
        return 'Unknown league';
      }
    } else if (level == 1) {
      return 'First league of $continent';
    } else {
      return 'Level $level league of $continent [${positionWithIndex(number)}/${1 << (level - 1)}]';
    }
  }
}
