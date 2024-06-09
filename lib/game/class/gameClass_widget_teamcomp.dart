part of 'gameClass.dart';

extension GameClassWidgetTeamcomps on GameClass {
  Widget getTeamcompsTab(BuildContext context, {bool isSpaceEvenly = false}) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                text: leftClub.club_name,
                // text: leftClub.getClubNameClickable(context),
              ),
              Tab(
                text: rightClub.club_name,
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [_getTeamComp(context, leftClub), Text('Right Club')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTeamComp(BuildContext context, Club club) {
    if (club.teamcomp == {null}) {
      return Center(
        child:
            Text('ERROR: No team composition available for ${club.club_name}'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPlayerCard(context, club,
                    club.teamcomp!.getPlayerMapByName('Left Striker')),
                const SizedBox(width: 6.0),
                buildPlayerCard(context, club,
                    club.teamcomp!.getPlayerMapByName('Central Striker')),
                const SizedBox(width: 6.0),
                buildPlayerCard(context, club,
                    club.teamcomp!.getPlayerMapByName('Right Striker')),
              ],
            ),
            // const SizedBox(height: 6.0), // Add spacing between rows
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     buildPlayerCard('LeftWinger'),
            //     const SizedBox(width: 6.0),
            //     buildPlayerCard('LeftMidFielder'),
            //     const SizedBox(width: 6.0),
            //     buildPlayerCard('CentralMidFielder'),
            //     const SizedBox(width: 6.0),
            //     buildPlayerCard('RightMidFielder'),
            //     const SizedBox(width: 6.0),
            //     buildPlayerCard('RightWinger'),
            //   ],
            // ),
            // const SizedBox(height: 6.0), // Add spacing between rows
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     buildPlayerCard('LeftWingDefender'),
            //     const SizedBox(width: 6.0),
            //     buildPlayerCard('LeftCentralDefender'),
            //     const SizedBox(width: 6.0),
            //     buildPlayerCard('CentralDefender'),
            //     const SizedBox(width: 6.0),
            //     buildPlayerCard('RightCentralDefender'),
            //     const SizedBox(width: 6.0),
            //     buildPlayerCard('RightWingDefender'),
            //   ],
            // ),
            // const SizedBox(height: 6.0), // Add spacing between rows
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     buildPlayerCard('GoalKeeper'),
            //   ],
            // ),
            // const SizedBox(
            //     height: 16.0), // Add spacing between rows
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     buildPlayerCard('Substitute 1', teamComp[index].idSub1),
            //     buildPlayerCard('Substitute 2', teamComp[index].idSub2),
            //     buildPlayerCard('Substitute 3', teamComp[index].idSub3),
            //     buildPlayerCard('Substitute 4', teamComp[index].idSub4),
            //     buildPlayerCard('Substitute 5', teamComp[index].idSub5),
            //     buildPlayerCard('Substitute 6', teamComp[index].idSub6),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildPlayerCard(
      BuildContext context, Club club, Map<String, dynamic>? player) {
    print(player);
    String strPositionInUI;

    if (player == null || player.isEmpty) {
      return Container(
          color: Colors.blueGrey,
          child: Center(child: Text('ERROR: player doesn\'t exist')));
    }

    switch (player['name']) {
      case 'GoalKeeper':
        strPositionInUI = 'GK';
        break;
      case 'LeftWingDefender':
        strPositionInUI = 'LB';
        break;
      case 'LeftCentralDefender':
        strPositionInUI = 'LCB';
        break;
      case 'CentralDefender':
        strPositionInUI = 'CB';
        break;
      case 'RightCentralDefender':
        strPositionInUI = 'RCB';
        break;
      case 'RightWingDefender':
        strPositionInUI = 'RB';
        break;
      case 'LeftWinger':
        strPositionInUI = 'LW';
        break;
      case 'LeftMidFielder':
        strPositionInUI = 'LCM';
        break;
      case 'CentralMidFielder':
        strPositionInUI = 'CM';
        break;
      case 'RightMidFielder':
        strPositionInUI = 'RCM';
        break;
      case 'RightWinger':
        strPositionInUI = 'RW';
        break;
      case 'Left Striker':
        strPositionInUI = 'LS';
        break;
      case 'Central Striker':
        strPositionInUI = 'S';
        break;
      case 'Right Striker':
        strPositionInUI = 'RS';
        break;
      default:
        throw ArgumentError('Invalid position: ${player['name']}');
    }

    return GestureDetector(
      onTap: () async {
        final returnedId = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return PlayersPage(
                inputCriteria: {
                  'Clubs': [club.id_club]
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

        if (returnedId != null) {
          await supabase
              .from('games_team_comp')
              .update({player['database']: returnedId});
        }
      },
      child: Container(
        color: player['player'] != null ? Colors.green : Colors.blueGrey,
        child: Column(
          children: [
            Text(strPositionInUI),
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
                              print('Delete player');
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
                            '${player['player'].first_name[0].toUpperCase()}.${player['player'].last_name}',
                            style: const TextStyle(fontSize: 12.0),
                          ),
                        ],
                      )
                    : const Icon(Icons.add,
                        size: 12,
                        color: Colors
                            .white), // Placeholder icon when player is null
                // child: Text(idPlayer != null ? idPlayer.toString() : 'NONE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
