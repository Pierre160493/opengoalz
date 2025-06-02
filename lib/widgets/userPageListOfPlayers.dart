import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerCard_Main.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/widgets/creationDialogBox_Player.dart';

Widget userPlayerListWidget(BuildContext context, Profile user) {
  // If user has no club, show the ListTile with possibility of creating a club

  return Column(
    children: [
      formSpacer6,

      /// List of players
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: user.playersIncarnated.length,
          itemBuilder: (context, index) {
            final Player player = user.playersIncarnated[index];
            return InkWell(
              onTap: () {
                print('Player tapped');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayersPage(
                      playerSearchCriterias:
                          PlayerSearchCriterias(idPlayer: [player.id]),
                    ),
                  ),
                );
              },
              child: PlayerCard(
                  player: player,
                  index: user.playersIncarnated.length == 1 ? 0 : index + 1,
                  isExpanded:
                      user.playersIncarnated.length == 1 ? true : false),
            );
          },
        ),
      ),

      /// Add player list tile
      ListTile(
        shape: shapePersoRoundedBorder(Colors.green),
        leading: Icon(
            user.playersIncarnated.length > 1
                ? Icons.person_add_alt_1
                : Icons.group_add,
            color: Colors.green),
        title: Text(user.playersIncarnated.length == 0
            ? 'You dont have any players yet'
            : 'Get an additional player'),
        subtitle: const Text('Create a player and start an amazing career !',
            style:
                TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic)),
        onTap: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return CreationDialogBox_Player();
          },
        ),
      ),
    ],
  );
}
