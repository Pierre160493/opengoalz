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
                for (var teamComp in teamComps) {
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
                                game.getGameRow(context),
                                game.getGameReport(context),
                                // game.getGameDetail(context),
                                // _getGameReport(game.events, context),
                                // _getTeamsComp(events, context),
                                Column(
                                  children: [
                                    Text('idGame: ' + game.id.toString()),
                                    Text('leftClub: ' +
                                        game.leftClub.club_name.toString() +
                                        game.leftClub.players.length
                                            .toString()),
                                    Text('rightClub: ' +
                                        game.rightClub.club_name.toString() +
                                        game.rightClub.players.length
                                            .toString()),
                                    Text('Game:' +
                                        game.leftClub.teamcomp!.id.toString()),
                                    Text('Game:' +
                                        game.leftClub.teamcomp!.idClub
                                            .toString()),
                                    // Text(game.leftClub.teamcomp!.goalKeeper!
                                    //     .toString()),
                                  ],
                                ),
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

  // Widget _getGameReport(List<GameEvent> events, BuildContext context) {
  //   int leftClubScore = 0;
  //   int rightClubScore = 0;

  //   if (events.length == 0) return Text('No events found');

  //   return Column(
  //     children: [
  //       SizedBox(
  //         height: 12,
  //       ),
  //       Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
  //         SizedBox(),
  //         InkWell(
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               ClubPage.route(game.idClubLeft),
  //             );
  //           },
  //           child: Row(
  //             children: [
  //               Icon(Icons.home),
  //               SizedBox(
  //                 width: 12,
  //               ),
  //               Text(
  //                 game.nameClubLeft,
  //                 style:
  //                     TextStyle(fontSize: 24), // Increase the font size to 20
  //               ),
  //             ],
  //           ),
  //         ),
  //         Icon(
  //           Icons.compare_arrows,
  //           size: 30,
  //           color: Colors.green,
  //         ),
  //         InkWell(
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               ClubPage.route(game.idClubRight),
  //             );
  //           },
  //           child: Row(
  //             children: [
  //               Text(
  //                 game.nameClubRight,
  //                 style:
  //                     TextStyle(fontSize: 24), // Increase the font size to 20
  //               ),
  //               SizedBox(
  //                 width: 12,
  //               ),
  //               Icon(Icons.home),
  //             ],
  //           ),
  //         ),
  //         // SizedBox(),
  //       ]),
  //       Expanded(
  //         child: ListView.builder(
  //           itemCount: events.length,
  //           itemBuilder: (context, index) {
  //             final event = events[index];

  //             if (index == 0) {
  //               leftClubScore = 0;
  //               rightClubScore = 0;
  //             }

  //             // Update scores based on event type (assuming event type 1 is a goal)
  //             if (event.idEventType == 1) {
  //               if (event.id_club == game.idClubLeft) {
  //                 leftClubScore++;
  //               } else if (event.id_club == game.idClubRight) {
  //                 rightClubScore++;
  //               }
  //             }

  //             return ListTile(
  //               leading: Container(
  //                 width: 100, // Fixed width to ensure alignment
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Container(
  //                       width: 36,
  //                       height: 36,
  //                       decoration: BoxDecoration(
  //                         shape: BoxShape.circle,
  //                         color: Colors.blueGrey,
  //                       ),
  //                       child: Center(
  //                         child: Text(
  //                           '${event.gameMinute.toString()}\'',
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 16.0,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(width: 10),
  //                     if (event.idEventType == 1) // Conditionally display score
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 8.0),
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Text(
  //                               '$leftClubScore - $rightClubScore',
  //                               style: TextStyle(
  //                                 fontSize: 16.0,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //               title: Row(
  //                 children: [
  //                   event.id_club == game.idClubRight
  //                       ? Spacer()
  //                       : SizedBox(width: 6),
  //                   event.getDescription(context),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _getTeamsComp(List<GameEvent> events, BuildContext context) {
  //   int leftClubScore = 0;
  //   int rightClubScore = 0;
  //   return ListView.builder(
  //     itemCount: events.length,
  //     itemBuilder: (context, index) {
  //       final event = events[index];

  //       // Update scores based on event type (assuming event type 1 is a goal)
  //       if (event.idEventType == 1) {
  //         if (event.id_club == widget.game.idClubLeft) {
  //           leftClubScore++;
  //         } else if (event.id_club == widget.game.idClubRight) {
  //           rightClubScore++;
  //         }
  //       }

  //       return ListTile(
  //         leading: Container(
  //           width: 100, // Fixed width to ensure alignment
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(
  //                 width: 36,
  //                 height: 36,
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   color: Colors.blueGrey,
  //                 ),
  //                 child: Center(
  //                   child: Text(
  //                     '${event.gameMinute.toString()}\'',
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 16.0,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(width: 10),
  //               if (event.idEventType == 1) // Conditionally display score
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 8.0),
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Text(
  //                         '$leftClubScore - $rightClubScore',
  //                         style: TextStyle(
  //                           fontSize: 16.0,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ),
  //         title: Row(
  //           children: [
  //             event.id_club == widget.game.idClubRight
  //                 ? Spacer()
  //                 : SizedBox(width: 6),
  //             // Icon(Icons.home_filled, color: Colors.blueGrey),
  //             event.id_club == widget.game.idClubLeft
  //                 ? widget.game.getLeftClubName()
  //                 : widget.game.getRightClubName(),
  //           ],
  //         ),
  //         subtitle: Row(
  //           children: [
  //             event.id_club == widget.game.idClubRight
  //                 ? Spacer()
  //                 : SizedBox(width: 6),
  //             event.getDescription(context),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
