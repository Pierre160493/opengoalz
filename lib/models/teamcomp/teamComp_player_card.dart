part of 'teamComp.dart';

extension TeamCompPlayerCard on TeamComp {
  Widget _playerTeamCompCard(
      BuildContext context, double width, Map<String, dynamic>? playerMap) {
    if (playerMap == null || playerMap.isEmpty) {
      return Container(
          color: Colors.blueGrey,
          child: Center(child: Text('ERROR: player doesn\'t exist')));
    }

    Player? player = playerMap['player'];

    /// If there is a player
    if (player != null) {
      return Tooltip(
        message: player.firstName + ' ' + player.lastName.toUpperCase(),
        child: InkWell(
          onTap: () async {
            /// Display the dialog box before navigating
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Current player for ${playerMap['name']}'),
                  // content: Text('Are you sure you want to navigate?'),
                  content: Container(
                    width: min(MediaQuery.of(context).size.width,
                        maxWidth), // 80% of screen width
                    child: SingleChildScrollView(
                      child: PlayerCard(
                        player: player,
                        isExpanded: true,
                      ),
                    ),
                  ),
                  actions: [
                    /// Substitute player
                    TextButton(
                      child: Text(selectedPlayerForSubstitution == null
                          ? 'Select ${player.firstName} ${player.lastName} for substitution'
                          : 'Substitute with ${selectedPlayerForSubstitution!.firstName} ${selectedPlayerForSubstitution!.lastName}'),
                      onPressed: () async {
                        // If no player is selected, it mens this is the first player selected
                        if (selectedPlayerForSubstitution == null) {
                          context.showSnackBar(
                              'Select the player you wish to substitute ${player.firstName} ${player.lastName} with ?',
                              icon: Icon(iconSuccessfulOperation,
                                  color: Colors.green));
                          // Set the idSelected Player as the selected player
                          selectedPlayerForSubstitution = player;
                        } else {
                          /// Check player cannot be substituted with himself
                          if (selectedPlayerForSubstitution!.id == player.id) {
                            context.showSnackBarError(
                              'You cannot substitute a player with himself !',
                            );
                          } else {
                            /// Set the minute and condition of the substitution
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
                                      /// Minute of the game when to substitute the player
                                      ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              12), // Adjust border radius as needed
                                          side: const BorderSide(
                                            color:
                                                Colors.blueGrey, // Border color
                                          ),
                                        ),
                                        leading: Icon(
                                          iconGames,
                                          size: iconSizeMedium,
                                        ),
                                        title: Text(
                                          'Minute of the game', // Replace with your title
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
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          validator: (value) {
                                            if (value != null &&
                                                int.tryParse(value) == null) {
                                              return 'Invalid type (should be an integer)'; // Return an empty string to show the error without any message
                                            }
                                            return null;
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction, // Validate whenever the user changes the value
                                        ),
                                      ),

                                      /// Condition (goal difference) of the game when to substitute the player
                                      ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              12), // Adjust border radius as needed
                                          side: const BorderSide(
                                            color:
                                                Colors.blueGrey, // Border color
                                          ),
                                        ),
                                        leading: Icon(
                                          Icons.question_mark,
                                          size: iconSizeMedium,
                                        ),
                                        title: Text(
                                          'Score difference of the game', // Replace with your title
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
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          validator: (value) {
                                            if (value != null &&
                                                int.tryParse(value) == null) {
                                              return 'Invalid type (should be an integer)'; // Return an empty string to show the error without any message
                                            }
                                            return null;
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction, // Validate whenever the user changes the value
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
                                int.tryParse(conditionController.text) ==
                                    null) {
                              context.showSnackBarError(
                                'The condition of substitution is not valid !',
                              );
                            } else {
                              bool isOK = await operationInDB(
                                  context, 'INSERT', 'game_orders',
                                  data: {
                                    'id_teamcomp': id,
                                    'id_player_out':
                                        selectedPlayerForSubstitution!.id,
                                    'id_player_in': player.id,
                                    'minute': minuteController.text.isEmpty
                                        ? null
                                        : int.parse(minuteController.text),
                                    'condition': conditionController
                                            .text.isEmpty
                                        ? null
                                        : int.parse(conditionController.text),
                                  });
                              if (isOK) {
                                context.showSnackBar(
                                    'Successfully set substitution of ${selectedPlayerForSubstitution!.firstName} ${selectedPlayerForSubstitution!.lastName} with ${player.firstName} ${player.lastName}',
                                    icon: Icon(iconSuccessfulOperation,
                                        color: Colors.green));
                              }
                            }
                            selectedPlayerForSubstitution = null;
                          }
                        }
                        Navigator.of(context).pop();
                      },
                    ),

                    /// Remove the player from the teamcomp
                    TextButton(
                      child: Text('Remove'),
                      onPressed: () async {
                        bool isOK = await operationInDB(
                            context, 'UPDATE', 'games_teamcomp',
                            data: {playerMap['database']: null},
                            matchCriteria: {'id': id});
                        if (isOK) {
                          context.showSnackBar(
                              'Successfully removed ${player.firstName} ${player.lastName} from the teamcomp',
                              icon: Icon(iconSuccessfulOperation,
                                  color: Colors.green));
                        }
                        Navigator.of(context).pop();
                      },
                    ),

                    /// Cancel ==> do nothing
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
            width: width,
            height: width * 1.2,
            child: Card(
              color: selectedPlayerForSubstitution != null &&
                      selectedPlayerForSubstitution!.id == player.id
                  ? Colors.amber
                  : Colors.green,
              elevation: 3.0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          player.getAgeWidgetSmall(),
                        ],
                      ),
                      Row(
                        children: [
                          if (player.shirtNumber != null)
                            Text('# ' + player.shirtNumber.toString()),
                          SizedBox(width: 3.0),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        player.getPlayerIcon(),
                        size: iconSizeLarge,
                      ),
                      player.getPlayerNameToolTip(context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      /// If there is no player
    } else {
      return Tooltip(
        message: 'Add a player',
        child: InkWell(
          onTap: () async {
            Player? returnedPlayer = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return PlayersPage(
                    playerSearchCriterias:
                        PlayerSearchCriterias(idClub: [idClub]),
                    isReturningPlayer: true,
                  );
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );

            /// Then we update the games_teamcomp table with the new player
            if (returnedPlayer != null) {
              bool isOK = await operationInDB(
                  context, 'UPDATE', 'games_teamcomp',
                  data: {playerMap['database']: returnedPlayer.id},
                  matchCriteria: {'id': id});
              if (isOK) {
                context.showSnackBar(
                    'Successfully set ${returnedPlayer.firstName} ${returnedPlayer.lastName} as ${playerMap['name']}',
                    icon: Icon(iconSuccessfulOperation, color: Colors.green));
              }
            }
          },
          child: Container(
            color: Colors.blueGrey,
            child: Icon(Icons.add, size: iconSizeLarge),
          ),
        ),
      );
    }
  }
}
