import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/events/event.dart';
import 'package:opengoalz/game/class/gameClass.dart';
import 'package:opengoalz/classes/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/player/class/player.dart';
import 'package:rxdart/rxdart.dart';

class GamePage extends StatefulWidget {
  final int idGame;
  const GamePage({Key? key, required this.idGame}) : super(key: key);

  static Route<void> route(int idGame) {
    return MaterialPageRoute(
      builder: (context) => GamePage(idGame: idGame),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<GamePage> {
  late Stream<GameClass> _gameStream;
  // late Stream<List<GameEvent>> _eventStream;

  @override
  void initState() {
    super.initState();

    // Stream to fetch the game
    _gameStream = supabase
        .from('games')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idGame)
        .map((maps) => maps.map((map) => GameClass.fromMap(map)).first)

        /// Fetch and assign the clubs of the game
        // Left Club
        .switchMap((game) {
          final leftClubStream = supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('id', game.idClubLeft)
              .map((maps) => maps
                  .map((map) => Club.fromMap(
                      map: map, myUserId: supabase.auth.currentUser!.id))
                  .toList());
          return leftClubStream.map((clubs) {
            if (clubs.length != 1) {
              throw Exception(
                  'DATABASE ERROR: ${clubs.length} club(s) found instead of 1 for the left club (with id: ${game.idClubLeft}) for the game with id: ${game.id}');
            }
            game.leftClub = clubs.first;
            return game;
          });
        })
        // Right Club
        .switchMap((game) {
          final rightClubStream = supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('id', game.idClubRight)
              .map((maps) => maps
                  .map((map) => Club.fromMap(
                      map: map, myUserId: supabase.auth.currentUser!.id))
                  .toList());
          return rightClubStream.map((clubs) {
            if (clubs.length != 1) {
              throw Exception(
                  'DATABASE ERROR: ${clubs.length} club(s) found instead of 1 for the right club (with id: ${game.idClubLeft}) for the game with id: ${game.id}');
            }
            game.rightClub = clubs.first;
            return game;
          });
        })
        // Fetch and assign team compositions
        .switchMap((game) {
          return supabase
              .from('games_team_comp')
              .stream(primaryKey: ['id'])
              .eq('id_game', game.id)
              .map((maps) => maps.map((map) => TeamComp.fromMap(map)).toList())
              .map((teamComps) {
                if (teamComps.length != 2) {
                  throw Exception(
                      'DATABASE ERROR: ${teamComps.length} teamcomps found instead of 2 for game with id: ${game.id}');
                }
                print('testPierre');
                for (TeamComp teamComp in teamComps) {
                  if (teamComp.idClub == game.idClubLeft) {
                    game.leftClub.teamcomp = teamComp;
                  } else if (teamComp.idClub == game.idClubRight) {
                    game.rightClub.teamcomp = teamComp;
                  } else {
                    throw Exception(
                        'DATABASE ERROR: Teamcomp with id: ${teamComp.id} does not belong to any of the clubs of the game with id: ${game.id}');
                  }
                }
                return game;
              });
        })
        .switchMap((game) {
          final playersStream = supabase
              .from('players')
              .stream(primaryKey: ['id']).inFilter('id', [
            ...game.leftClub.teamcomp!
                .to_list_int()
                .where((id) => id != null)
                .cast<int>(),
            ...game.rightClub.teamcomp!
                .to_list_int()
                .where((id) => id != null)
                .cast<int>()
          ]).map((maps) => maps.map((map) => Player.fromMap(map)).toList());

          return playersStream.map((players) {
            // print('Number of players: ' + players.length.toString());
            game.leftClub.teamcomp!.init_players(players
                // .where((player) => player.id_club == game.idClubLeft)
                // .toList()
                );
            // game.rightClub.teamcomp!.init_players(players
            //     .where((player) => player.id_club == game.idClubRight)
            //     .toList());
            return game;
          });
        })
        .switchMap((game) {
          final _eventStream = supabase
              .from('game_events')
              .stream(primaryKey: ['id'])
              .eq('id_game', widget.idGame)
              .map(
                  (maps) => maps.map((map) => GameEvent.fromMap(map)).toList());
          return _eventStream.map((events) {
            game.events = events;
            return game;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GameClass>(
        stream: _gameStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('ERROR: ${snapshot.error}'),
            );
          } else {
            // final players = snapshot.data ?? [];
            final GameClass game = (snapshot.data ?? []) as GameClass;

            return Scaffold(
              appBar: AppBar(
                  title:
                      game.getGameRow(context)), //Row presentation of the game
              body: Center(
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: 600), // Set your desired maximum width
                  child: DefaultTabController(
                      length: 3, // Number of tabs
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            tabs: [
                              Tab(text: 'Details'),
                              Tab(text: 'Report'),
                              Tab(text: 'Teams'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                game.getGameRow(context, isSpaceEvenly: true),
                                game.getGameReport(context),
                                DefaultTabController(
                                  length: 2,
                                  child: Column(
                                    children: [
                                      TabBar(
                                        tabs: [
                                          Tab(
                                            text: game.leftClub.club_name,
                                          ),
                                          Tab(
                                            text: game.rightClub.club_name,
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          children: [
                                            Text('Left Club'),
                                            Text('Right Club')
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )

                                // game.getTeamsComp(context)
                                // Column(
                                //   children: [
                                //     Text('idGame: ' + game.id.toString()),
                                //     Text('leftClub: ' +
                                //         game.leftClub.club_name.toString() +
                                //         game.leftClub.players.length
                                //             .toString()),
                                //     Text('rightClub: ' +
                                //         game.rightClub.club_name.toString() +
                                //         game.rightClub.players.length
                                //             .toString()),
                                //     Text('Game:' +
                                //         game.leftClub.teamcomp!.id.toString()),
                                //     Text('Game:' +
                                //         game.leftClub.teamcomp!.idClub
                                //             .toString()),
                                //     // Text(game.leftClub.teamcomp!.goalKeeper!
                                //     //     .toString()),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            );
          }
        });
  }

  // Widget _getTeamsComp(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.all(16.0),
  //     child: SingleChildScrollView(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               buildPlayerCard(game.tea),
  //               const SizedBox(width: 6.0),
  //               buildPlayerCard('CentralStriker'),
  //               const SizedBox(width: 6.0),
  //               buildPlayerCard('RightStriker'),
  //             ],
  //           ),
  //           const SizedBox(height: 6.0), // Add spacing between rows
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               buildPlayerCard('LeftWinger'),
  //               const SizedBox(width: 6.0),
  //               buildPlayerCard('LeftMidFielder'),
  //               const SizedBox(width: 6.0),
  //               buildPlayerCard('CentralMidFielder'),
  //               const SizedBox(width: 6.0),
  //               buildPlayerCard('RightMidFielder'),
  //               const SizedBox(width: 6.0),
  //               buildPlayerCard('RightWinger'),
  //             ],
  //           ),
  //           const SizedBox(height: 6.0), // Add spacing between rows
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               buildPlayerCard('LeftWingDefender'),
  //               const SizedBox(width: 6.0),
  //               buildPlayerCard('LeftCentralDefender'),
  //               const SizedBox(width: 6.0),
  //               buildPlayerCard('CentralDefender'),
  //               const SizedBox(width: 6.0),
  //               buildPlayerCard('RightCentralDefender'),
  //               const SizedBox(width: 6.0),
  //               buildPlayerCard('RightWingDefender'),
  //             ],
  //           ),
  //           const SizedBox(height: 6.0), // Add spacing between rows
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               buildPlayerCard('GoalKeeper'),
  //             ],
  //           ),
  //           // const SizedBox(
  //           //     height: 16.0), // Add spacing between rows
  //           // Row(
  //           //   mainAxisAlignment: MainAxisAlignment.center,
  //           //   children: [
  //           //     buildPlayerCard('Substitute 1', teamComp[index].idSub1),
  //           //     buildPlayerCard('Substitute 2', teamComp[index].idSub2),
  //           //     buildPlayerCard('Substitute 3', teamComp[index].idSub3),
  //           //     buildPlayerCard('Substitute 4', teamComp[index].idSub4),
  //           //     buildPlayerCard('Substitute 5', teamComp[index].idSub5),
  //           //     buildPlayerCard('Substitute 6', teamComp[index].idSub6),
  //           //   ],
  //           // ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget buildPlayerCard(Map<String, dynamic> player) {
  //   int? idPlayer;
  //   String strPositionInDB, strPositionInUI;

  //   switch (position) {
  //     case 'GoalKeeper':
  //       idPlayer = teamComp.idGoalKeeper;
  //       strPositionInDB = 'idgoalkeeper';
  //       strPositionInUI = 'GoalKeeper';
  //       strPositionInUI = 'GK';
  //       break;
  //     case 'LeftWingDefender':
  //       idPlayer = teamComp.idLeftBackWinger;
  //       strPositionInDB = 'idleftbackwinger';
  //       strPositionInUI = 'Left Back';
  //       strPositionInUI = 'LB';
  //       break;
  //     case 'LeftCentralDefender':
  //       idPlayer = teamComp.idLeftCentralBack;
  //       strPositionInDB = 'idleftcentralback';
  //       strPositionInUI = 'Central Def';
  //       strPositionInUI = 'LCB';
  //       break;
  //     case 'CentralDefender':
  //       idPlayer = teamComp.idCentralBack;
  //       strPositionInDB = 'idcentralback';
  //       strPositionInUI = 'Central Def';
  //       strPositionInUI = 'CB';
  //       break;
  //     case 'RightCentralDefender':
  //       idPlayer = teamComp.idRightCentralBack;
  //       strPositionInDB = 'idrightcentralback';
  //       strPositionInUI = 'Central Def';
  //       strPositionInUI = 'RCB';
  //       break;
  //     case 'RightWingDefender':
  //       idPlayer = teamComp.idRightBackWinger;
  //       strPositionInDB = 'idrightbackwinger';
  //       strPositionInUI = 'Right Back';
  //       strPositionInUI = 'RB';
  //       break;
  //     case 'LeftWinger':
  //       idPlayer = teamComp.idLeftWinger;
  //       strPositionInDB = 'idleftwinger';
  //       strPositionInUI = 'Left Winger';
  //       strPositionInUI = 'LW';
  //       break;
  //     case 'LeftMidFielder':
  //       idPlayer = teamComp.idLeftMidFielder;
  //       strPositionInDB = 'idleftmidfielder';
  //       strPositionInUI = 'MidFielder';
  //       strPositionInUI = 'LCM';
  //       break;
  //     case 'CentralMidFielder':
  //       idPlayer = teamComp.idCentralMidFielder;
  //       strPositionInDB = 'idcentralmidfielder';
  //       strPositionInUI = 'MidFielder';
  //       strPositionInUI = 'CM';
  //       break;
  //     case 'RightMidFielder':
  //       idPlayer = teamComp.idRightMidFielder;
  //       strPositionInDB = 'idrightmidfielder';
  //       strPositionInUI = 'MidFielder';
  //       strPositionInUI = 'RCM';
  //       break;
  //     case 'RightWinger':
  //       idPlayer = teamComp.idRightWinger;
  //       strPositionInDB = 'idrightwinger';
  //       strPositionInUI = 'Right Winger';
  //       strPositionInUI = 'RW';
  //       break;
  //     case 'LeftStriker':
  //       idPlayer = teamComp.idLeftStriker;
  //       strPositionInDB = 'idleftstriker';
  //       strPositionInUI = 'Striker';
  //       strPositionInUI = 'LS';
  //       break;
  //     case 'CentralStriker':
  //       idPlayer = teamComp.idCentralStriker;
  //       strPositionInDB = 'idcentralstriker';
  //       strPositionInUI = 'Striker';
  //       strPositionInUI = 'S';
  //       break;
  //     case 'RightStriker':
  //       idPlayer = teamComp.idRightStriker;
  //       strPositionInDB = 'idrightstriker';
  //       strPositionInUI = 'Striker';
  //       strPositionInUI = 'RS';
  //       break;
  //     default:
  //       throw ArgumentError('Invalid position: $position');
  //   }

  //   final Player? player = idPlayer != null
  //       ? players.firstWhere(
  //           (player) => player.id == idPlayer,
  //         )
  //       : null;

  //   return GestureDetector(
  //     onTap: () async {
  //       final returnedId = await Navigator.push(
  //         context,
  //         PageRouteBuilder(
  //           pageBuilder: (context, animation, secondaryAnimation) {
  //             return PlayersPage(
  //               inputCriteria: {
  //                 'Clubs': [widget.game.idClub]
  //               },
  //               isReturningId: true,
  //             );
  //           },
  //           transitionsBuilder:
  //               (context, animation, secondaryAnimation, child) {
  //             return SlideTransition(
  //               position: Tween<Offset>(
  //                 begin: const Offset(1.0, 0.0),
  //                 end: Offset.zero,
  //               ).animate(animation),
  //               child: child,
  //             );
  //           },
  //         ),
  //       );

  //       if (returnedId != null) {
  //         // Use the returnedId here as needed
  //         print('Returned player ID: $returnedId for game: ${teamComp.id}');

  //         await supabase
  //             .from('games_team_comp')
  //             .update({strPositionInDB: returnedId}).match({'id': teamComp.id});
  //       }
  //     },
  //     child: Container(
  //       color: player != null ? Colors.green : Colors.blueGrey,
  //       child: Column(
  //         children: [
  //           Text(strPositionInUI),
  //           Card(
  //             elevation: 3.0,
  //             child: Container(
  //               width: 48.0,
  //               height: 60.0,
  //               alignment: Alignment.center,
  //               child: player != null
  //                   ? Column(
  //                       children: [
  //                         GestureDetector(
  //                           onTap: () async {
  //                             print('Delete player');
  //                             await supabase
  //                                 .from('games_team_comp')
  //                                 .update({strPositionInDB: null}).match(
  //                                     {'id': teamComp.id});
  //                           },
  //                           child: const Row(
  //                             mainAxisAlignment: MainAxisAlignment.end,
  //                             children: [
  //                               Icon(
  //                                 Icons
  //                                     .restore_from_trash, // Your additional icon
  //                                 size: 6,
  //                                 color: Colors.red,
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         const Icon(Icons.person,
  //                             size: 12, color: Colors.white),
  //                         Text(
  //                           '${player.first_name[0].toUpperCase()}.${player.last_name}',
  //                           style: const TextStyle(fontSize: 12.0),
  //                         ),
  //                       ],
  //                     )
  //                   : const Icon(Icons.add,
  //                       size: 12,
  //                       color: Colors
  //                           .white), // Placeholder icon when player is null
  //               // child: Text(idPlayer != null ? idPlayer.toString() : 'NONE'),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
