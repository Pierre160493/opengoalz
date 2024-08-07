part of 'teamComp.dart';

extension TeamCompWidgetsHelper on TeamComp {
  Widget getTeamCompWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _playerTeamCompCard(
                    context, getPlayerMapByName('Left Striker')),
                const SizedBox(width: 6.0),
                _playerTeamCompCard(
                    context, getPlayerMapByName('Central Striker')),
                const SizedBox(width: 6.0),
                _playerTeamCompCard(
                    context, getPlayerMapByName('Right Striker')),
              ],
            ),
            const SizedBox(height: 6.0), // Add spacing between rows
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _playerTeamCompCard(context, getPlayerMapByName('Left Winger')),
                const SizedBox(width: 6.0),
                _playerTeamCompCard(
                    context, getPlayerMapByName('Left Midfielder')),
                const SizedBox(width: 6.0),
                _playerTeamCompCard(
                    context, getPlayerMapByName('Central Midfielder')),
                const SizedBox(width: 6.0),
                _playerTeamCompCard(
                    context, getPlayerMapByName('Right Midfielder')),
                const SizedBox(width: 6.0),
                _playerTeamCompCard(
                    context, getPlayerMapByName('Right Winger')),
              ],
            ),
            const SizedBox(height: 6.0), // Add spacing between rows
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _playerTeamCompCard(
                    context, getPlayerMapByName('Left Back Winger')),
                const SizedBox(width: 6.0),
                _playerTeamCompCard(
                    context, getPlayerMapByName('Left Central Back')),
                const SizedBox(width: 6.0),
                _playerTeamCompCard(
                    context, getPlayerMapByName('Central Back')),
                const SizedBox(width: 6.0),
                _playerTeamCompCard(
                    context, getPlayerMapByName('Right Central Back')),
                const SizedBox(width: 6.0),
                _playerTeamCompCard(
                    context, getPlayerMapByName('Right Back Winger')),
              ],
            ),
            const SizedBox(height: 6.0), // Add spacing between rows
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _playerTeamCompCard(context, getPlayerMapByName('Goal Keeper')),
              ],
            ),
            const SizedBox(height: 16.0), // Add spacing between rows
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _playerTeamCompCard(context, getPlayerMapByName('Sub 1')),
                _playerTeamCompCard(context, getPlayerMapByName('Sub 2')),
                _playerTeamCompCard(context, getPlayerMapByName('Sub 3')),
                _playerTeamCompCard(context, getPlayerMapByName('Sub 4')),
                _playerTeamCompCard(context, getPlayerMapByName('Sub 5')),
                _playerTeamCompCard(context, getPlayerMapByName('Sub 6')),
                _playerTeamCompCard(context, getPlayerMapByName('Sub 7')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerTeamCompCard(
      BuildContext context, Map<String, dynamic>? player) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (player == null || player.isEmpty) {
      return Container(
          color: Colors.blueGrey,
          child: Center(child: Text('ERROR: player doesn\'t exist')));
    }

    return InkWell(
      onTap: () async {
        /// If the game is already played, only open the player page
        // if (isPlayed) {
        //   if (player['id'] != null) {
        //     Navigator.push(
        //       context,
        //       PageRouteBuilder(
        //         pageBuilder: (context, animation, secondaryAnimation) {
        //           return PlayersPage(
        //             inputCriteria: {
        //               'Player': [player['player'].id]
        //             },
        //           );
        //         },
        //       ),
        //     );
        //   }

        //   /// Otherwise we give the possibility to change the player
        // } else {
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

        /// Then we update the games_team_comp table with the new player
        if (returnedId != null) {
          try {
            print(id);
            await supabase
                .from('games_team_comp')
                .update({player['database']: returnedId}).eq('id', id);
          } on PostgrestException catch (error) {
            print(error.message);
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
        color: player['player'] != null ? Colors.green : Colors.blueGrey,
        child: Column(
          children: [
            Card(
              elevation: 3.0,
              child: Container(
                width: 48.0,
                height: 60.0,
                alignment: Alignment.center,
                child: player['player'] != null
                    ? Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await supabase
                                  .from('games_team_comp')
                                  .update({player['database']: null}).match(
                                      {'id': player['player'].id});
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons
                                      .restore_from_trash, // Your additional icon
                                  size: 6,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.person,
                              size: 12, color: Colors.white),
                          Text(
                            '${player['player'].firstName[0].toUpperCase()}.${player['player'].lastName}',
                            // style: const TextStyle(fontSize: 12.0),
                          ),
                        ],
                      )
                    : const Icon(Icons.add,
                        size: 12,
                        color: Colors
                            .white), // Placeholder icon when player is null
              ),
            ),
          ],
        ),
      ),
    );
  }
}
