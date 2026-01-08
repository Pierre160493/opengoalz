import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/get_player_history_graph.dart';

class PlayerStaffCoefTile extends StatelessWidget {
  final Player player;
  final String title;

  const PlayerStaffCoefTile({
    Key? key,
    required this.player,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    int value;
    if (title == 'Coach') {
      icon = iconCoach;
      value = player.coefCoach;
    } else if (title == 'Scout') {
      icon = iconScout;
      value = player.coefScout;
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconError, color: Colors.red, size: iconSizeLarge * 2),
            Text('ERROR: $title is not a valid staff member'),
          ],
        ),
      );
    }
    return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Icon(
        icon,
        color: value >= 50
            ? Colors.green
            : value >= 25
                ? Colors.orange
                : Colors.red,
        size: iconSizeMedium,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: fontSizeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      subtitle: Text(
        '$title coefficient',
        style: styleItalicBlueGrey.copyWith(fontSize: fontSizeSmall),
      ),
      onTap: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return getPlayerHistoryGraph(
                context,
                player.id,
                [title == 'Coach' ? 'coef_coach' : 'coef_scout'],
                '$title coefficient');
          },
        );
      },
    );
  }
}
