part of 'teamComp.dart';

extension TeamCompWidgetsHelper on TeamComp {
  Widget getTeamCompWidget(BuildContext context) {
    double width =
        (min(MediaQuery.of(context).size.width, maxWidth) ~/ 6).toDouble();

    /// sizedBox resued for spacing between rows
    var sizedBox = SizedBox(width: width / 6);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Left Striker')),
                sizedBox,
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Central Striker')),
                sizedBox,
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
                sizedBox,
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Left Midfielder')),
                sizedBox,
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Central Midfielder')),
                sizedBox,
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Right Midfielder')),
                sizedBox,
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
                sizedBox,
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Left Central Back')),
                sizedBox,
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Central Back')),
                sizedBox,
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Right Central Back')),
                sizedBox,
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
            const SizedBox(height: 16.0), // Add spacing between rows
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
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Sub 1')),
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Sub 2')),
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Sub 3')),
              ],
            ),
            const SizedBox(height: 16.0), // Add spacing between rows
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Sub 4')),
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Sub 5')),
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Sub 6')),
                _playerTeamCompCard(
                    context, width, getPlayerMapByName('Sub 7')),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
                    /// Swap player by opening Players Page
                    TextButton(
                      child: Text('Swap'),
                      onPressed: () async {
                        final returnedId = await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return PlayersPage(
                                inputCriteria: {
                                  'Clubs': [idClub]
                                },
                                isReturningId: true,
                              );
                            },
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
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
                                .update({playerMap['database']: returnedId}).eq(
                                    'id', id);
                          } on PostgrestException catch (error) {
                            // print(error.message);
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content:
                                    Text('POSTGRES ERROR: ' + error.message),
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
                        Navigator.of(context).pop();
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
              color: Colors.green,
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
