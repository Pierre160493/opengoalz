import 'dart:math';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/pages/players_page.dart';
import 'package:opengoalz/models/player/widgets/cards/player_card.dart';
import 'package:opengoalz/models/player/widgets/player_icon.dart';
import 'package:opengoalz/models/player/widgets/player_shirt_number_icon.dart';
import 'package:opengoalz/models/player/widgets/player_small_notes_icon.dart';
import 'package:opengoalz/models/player/widgets/player_widgets.dart';
import 'package:opengoalz/models/player/widgets/player_name_tooltip.dart';
import 'package:opengoalz/models/playerPosition.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/playerStatsBest.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/postgresql_requests.dart';

class TeamCompPlayerCard extends StatefulWidget {
  final BuildContext context;
  final double width;
  final PlayerWithPosition playerWithPosition;
  final TeamComp teamComp;

  const TeamCompPlayerCard({
    Key? key,
    required this.context,
    required this.width,
    required this.playerWithPosition,
    required this.teamComp,
  }) : super(key: key);

  @override
  _PlayerTeamCompCardState createState() => _PlayerTeamCompCardState();
}

class _PlayerTeamCompCardState extends State<TeamCompPlayerCard> {
  @override
  Widget build(BuildContext context) {
    /// If there is no player defined at this position, show an add icon
    if (widget.playerWithPosition.player == null) {
      return InkWell(
        onTap: () async {
          final Player? player = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayersPage(
                playerSearchCriterias: PlayerSearchCriterias(
                  idClub: [widget.teamComp.idClub],
                  idPlayerRemove: widget.teamComp.playersWithPosition
                      .map((e) => e.player?.id)
                      .whereType<int>()
                      .toList(),
                ),
                isReturningPlayer: true,
              ),
            ),
          );
          if (player != null) {
            await operationInDB(
              context,
              'UPDATE',
              'games_teamcomp',
              data: {widget.playerWithPosition.database: player.id},
              matchCriteria: {'id': widget.teamComp.id},
              messageSuccess:
                  'Successfully added ${player.firstName} ${player.lastName} to the teamcomp',
            );
            setState(() {
              widget.playerWithPosition.player = player;
            });
          }
        },
        child: Card(
          elevation: 5.0,
          color: Colors.grey[850],
          child: Icon(
            Icons.add,
            color: Colors.green,
            size: iconSizeLarge,
          ),
        ),
      );
    }
    Player player = widget.playerWithPosition.player!;
    Player? selectedPlayerForSubstitution =
        widget.teamComp.selectedPlayerForSubstitution;
    int? idSelectedPlayerForSubstitution =
        widget.teamComp.selectedPlayerForSubstitution?.id;

    return InkWell(
      onTap: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title:
                  Text('Current player for ${widget.playerWithPosition.name}'),
              content: Container(
                width: min(MediaQuery.of(context).size.width, maxWidth),
                child: SingleChildScrollView(
                  child: PlayerCard(
                    player: player,
                    isExpanded: true,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(selectedPlayerForSubstitution == null
                      ? 'Select ${player.firstName} ${player.lastName} for substitution'
                      : 'Substitute with ${selectedPlayerForSubstitution.firstName} ${selectedPlayerForSubstitution.lastName}'),
                  onPressed: () async {
                    if (idSelectedPlayerForSubstitution == player.id) {
                      context.showSnackBarError(
                        'You cannot substitute a player with himself !',
                      );
                    } else {
                      final TextEditingController minuteController =
                          TextEditingController();
                      final TextEditingController conditionController =
                          TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                                'Enter the minute and condition for the substitution'),
                            content: Column(
                              children: [
                                ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  leading: Icon(
                                    iconGames,
                                    size: iconSizeMedium,
                                  ),
                                  title: Text(
                                    'Minute of the game',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: TextFormField(
                                    controller: minuteController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText:
                                          "Enter minute of the game when the substitution should take place",
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    validator: (value) {
                                      if (value != null &&
                                          int.tryParse(value) == null) {
                                        return 'Invalid type (should be an integer)';
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                ),
                                ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.question_mark,
                                    size: iconSizeMedium,
                                  ),
                                  title: Text(
                                    'Score difference of the game',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: TextFormField(
                                    controller: conditionController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText:
                                          "Enter the goal difference of the game when the substitution should take place",
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    validator: (value) {
                                      if (value != null &&
                                          int.tryParse(value) == null) {
                                        return 'Invalid type (should be an integer)';
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      if (!minuteController.text.isEmpty &&
                          int.tryParse(minuteController.text) == null) {
                        print(minuteController.text);
                        context.showSnackBarError(
                          'The minute of substitution is not valid !',
                        );
                      } else if (!conditionController.text.isEmpty &&
                          int.tryParse(conditionController.text) == null) {
                        context.showSnackBarError(
                          'The condition of substitution is not valid !',
                        );
                      } else {
                        await operationInDB(context, 'INSERT', 'game_orders',
                            data: {
                              'id_teamcomp': widget.teamComp.id,
                              'id_player_out': idSelectedPlayerForSubstitution,
                              'id_player_in': player.id,
                              'minute': minuteController.text.isEmpty
                                  ? null
                                  : int.parse(minuteController.text),
                              'condition': conditionController.text.isEmpty
                                  ? null
                                  : int.parse(conditionController.text),
                            },
                            messageSuccess:
                                'Successfully set substitution of ${selectedPlayerForSubstitution!.getFullName()} with ${player.getFullName()}');
                      }
                      setState(() {
                        widget.teamComp.selectedPlayerForSubstitution = null;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Remove'),
                  onPressed: () async {
                    await operationInDB(context, 'UPDATE', 'games_teamcomp',
                        data: {widget.playerWithPosition.database: null},
                        matchCriteria: {'id': widget.teamComp.id},
                        messageSuccess:
                            'Successfully removed ${player.getFullName()} from the teamcomp');
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: widget.width,
        height: widget.width * 1.2,
        child: Card(
          color: idSelectedPlayerForSubstitution == player.id
              ? Colors.amber
              // : Colors.black54,
              : Colors.grey[850],
          elevation: 3.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  player.getAgeWidgetSmall(),
                  PlayerShirtNumberIcon(player: player),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  player.gamePlayerStatsBest != null
                      ? buildStarIcon(
                          player.gamePlayerStatsBest!.stars, iconSizeLarge)
                      : PlayerIcon(
                          player: player,
                          size: iconSizeLarge,
                        ),
                  PlayerNameTooltip(player: player),
                ],
              ),
              Row(
                children: [
                  PlayerSmallNotesIcon(player: player),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
