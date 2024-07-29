part of 'league.dart';

extension LeagueWidgetHelper on League {
  /// Widget of the league name
  Widget getLeagueName() {
    return Row(
      children: [
        Text('League: ${level}.${number}'),
      ],
    );
  }

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
            child: getLeagueName()),
      ],
    );
  }

  /// Widget of the league name
  Widget getLeagueDescription() {
    return Row(
      children: [
        Text('Season ${seasonNumber} in ${continent}'),
      ],
    );
  }
}
