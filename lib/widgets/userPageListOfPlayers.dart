import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/clubCardWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/player_card.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/widgets/clubAndPlayerCreationDialogBox.dart';

Widget userPlayerListWidget(BuildContext context, Profile user) {
  // If user has no club, show the ListTile with possibility of creating a club

  return Column(
    children: [
      const SizedBox(height: 12),
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: user.players.length,
          itemBuilder: (context, index) {
            final Player player = user.players[index];
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
                  index: user.players.length == 1 ? 0 : index + 1,
                  isExpanded: user.players.length == 1 ? true : false),
            );
          },
        ),
      ),
      if (user.numberPlayersAvailable > user.players.length)
        ListTile(
          shape: shapePersoRoundedBorder(Colors.green),
          leading: Icon(
              user.players.length > 1
                  ? Icons.person_add_alt_1
                  : Icons.group_add,
              color: Colors.green),
          title: Text(user.players.length == 0
              ? 'You dont have any players yet'
              : 'Get an additional player'),
          subtitle: const Text('Create a player and start his amazing career !',
              style: TextStyle(
                  color: Colors.blueGrey, fontStyle: FontStyle.italic)),
          onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return AssignPlayerOrClubDialogBox(isClub: false);
            },
          ),
        ),
    ],
  );
}
