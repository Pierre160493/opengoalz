import 'package:flutter/material.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerCard_Main.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/user_page/user_page_add_player_tile.dart';

class UserPagePlayersTab extends StatelessWidget {
  final Profile user;

  const UserPagePlayersTab({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Add player tile
        UserPageAddPlayerTile(
          user: user,
        ),

        /// List of players
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: user.playersIncarnated.length,
            itemBuilder: (context, index) {
              final Player player = user.playersIncarnated[index];
              return InkWell(
                onTap: () {
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
                  isExpanded: user.playersIncarnated.length == 1 ? true : false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
