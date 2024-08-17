part of 'teamComp.dart';

extension TeamCompPlayerCard on TeamComp {
  Widget _playerTeamCompCard(
      BuildContext context, double width, Map<String, dynamic>? playerMap) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
                    // /// Swap player by opening Players Page
                    // TextButton(
                    //   child: Text('Swap'),
                    //   onPressed: () async {
                    //     final returnedId = await Navigator.push(
                    //       context,
                    //       PageRouteBuilder(
                    //         pageBuilder:
                    //             (context, animation, secondaryAnimation) {
                    //           return PlayersPage(
                    //             inputCriteria: {
                    //               'Clubs': [idClub]
                    //             },
                    //             isReturningId: true,
                    //           );
                    //         },
                    //         transitionsBuilder: (context, animation,
                    //             secondaryAnimation, child) {
                    //           return SlideTransition(
                    //             position: Tween<Offset>(
                    //               begin: const Offset(1.0, 0.0),
                    //               end: Offset.zero,
                    //             ).animate(animation),
                    //             child: child,
                    //           );
                    //         },
                    //       ),
                    //     );

                    //     /// Then we update the games_teamcomp table with the new player
                    //     if (returnedId != null) {
                    //       try {
                    //         await supabase
                    //             .from('games_teamcomp')
                    //             .update({playerMap['database']: returnedId}).eq(
                    //                 'id', id);
                    //       } on PostgrestException catch (error) {
                    //         // print(error.message);
                    //         scaffoldMessenger.showSnackBar(
                    //           SnackBar(
                    //             content:
                    //                 Text('POSTGRES ERROR: ' + error.message),
                    //           ),
                    //         );
                    //       } catch (error) {
                    //         scaffoldMessenger.showSnackBar(
                    //           SnackBar(
                    //             content: Text('An unexpected error occurred.'),
                    //           ),
                    //         );
                    //       }
                    //     }
                    //     Navigator.of(context).pop();
                    //   },
                    // ),

                    /// Substitute player
                    TextButton(
                      child: Text('Substitute'),
                      onPressed: () async {
                        if (idSelectedPlayer == null) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Which player do you wish to substitute ${player.firstName} ${player.lastName.toUpperCase()} with?'),
                            ),
                          );
                          idSelectedPlayer = player.id;
                        } else {
                          if (idSelectedPlayer == player.id) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                    'You cannot substitute a player with himself !'),
                              ),
                            );
                          } else {
                            /// Set the minute of substitution
                            final minuteController = TextEditingController();
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title:
                                      Text('Enter the minute of substitution'),
                                  content: TextField(
                                    controller: minuteController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        hintText: "Enter minute"),
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
                            if (int.tryParse(minuteController.text) != null) {
                              try {
                                await supabase.from('game_orders').insert({
                                  'id_teamcomp': id,
                                  'id_player_out': idSelectedPlayer,
                                  'id_player_in': player.id,
                                  // 'minute': int.parse(minuteController.text),
                                  'minute': 45,
                                });
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Successfully set substitution orders !'),
                                  ),
                                );
                              } on PostgrestException catch (error) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'POSTGRES ERROR: ' + error.message),
                                  ),
                                );
                              } catch (error) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('An unexpected error occurred.'),
                                  ),
                                );
                              }
                            } else {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'The minute of substitution is not valid !'),
                                ),
                              );
                            }
                            idSelectedPlayer = null;
                          }
                          Navigator.of(context).pop();
                        }
                      },
                    ),

                    /// Remove the player from the teamcomp
                    TextButton(
                      child: Text('Remove'),
                      onPressed: () async {
                        /// Set null
                        try {
                          await supabase.from('games_teamcomp').update(
                              {playerMap['database']: null}).eq('id', id);
                        } on PostgrestException catch (error) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('POSTGRES ERROR: ' + error.message),
                            ),
                          );
                        } catch (error) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('An unexpected error occurred.'),
                            ),
                          );
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
              color:
                  idSelectedPlayer == player.id ? Colors.amber : Colors.green,
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
                      player.getPlayerNames(context),
                      // Text(
                      //   player.firstName,
                      // ),
                      // Text(
                      //   player.lastName.toUpperCase(),
                      // ),
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
            final returnedId = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return PlayersPage(
                    inputCriteria: {
                      'Clubs': [idClub]
                    },
                    isReturningId: true,
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
            if (returnedId != null) {
              try {
                await supabase
                    .from('games_teamcomp')
                    .update({playerMap['database']: returnedId}).eq('id', id);
              } on PostgrestException catch (error) {
                // print(error.message);
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('POSTGRES ERROR: ' + error.message),
                  ),
                );
              } catch (error) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('An unexpected error occurred.'),
                  ),
                );
              }
            }
            // }
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
