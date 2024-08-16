part of 'teamComp.dart';

extension TeamCompTab on TeamComp {
  Widget getTeamCompWidget(BuildContext context) {
    double width =
        (min(MediaQuery.of(context).size.width, maxWidth) ~/ 6).toDouble();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 1.0, // Set border width
        ),
      ),
      width: width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _getStartingTeam(context, width),
            const SizedBox(height: 16.0), // Add spacing between rows
            _getSubstitutes(context, width)
          ],
        ),
      ),
    );
  }

  Widget _getStartingTeam(BuildContext context, double width) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Left Striker')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Central Striker')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Right Striker')),
          ],
        ),
        const SizedBox(height: 6.0), // Add spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Left Winger')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Left Midfielder')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Central Midfielder')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Right Midfielder')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Right Winger')),
          ],
        ),
        const SizedBox(height: 6.0), // Add spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Left Back Winger')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Left Central Back')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Central Back')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Right Central Back')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Right Back Winger')),
          ],
        ),
        const SizedBox(height: 6.0), // Add spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Goal Keeper')),
          ],
        ),
      ],
    );
  }

  Widget _getSubstitutes(BuildContext context, double width) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('Substitutes'),
                Icon(Icons.weekend, size: iconSizeLarge),
              ],
            ),
            SizedBox(width: 6.0),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 1')),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 2')),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 3')),
          ],
        ),
        const SizedBox(height: 16.0), // Add spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 4')),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 5')),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 6')),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 7')),
          ],
        ),
      ],
    );
  }
}
