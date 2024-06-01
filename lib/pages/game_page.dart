import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/event.dart';
import 'package:opengoalz/classes/gameClass.dart';
import 'package:opengoalz/classes/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/club_page.dart';
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
  late Stream<List<Club>> _clubStream;
  late Stream<List<TeamComp>> _teamCompStream;
  late Stream<List<Player>> _playerStream;
  late Stream<List<GameEvent>> _eventStream;

  @override
  void initState() {
    // Stream to fetch the game
    _gameStream = supabase
        .from('games')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idGame)
        .map((maps) => maps.map((map) => GameClass.fromMap(map)).first);
    ;

    // Stream to fetch clubs related to the game
    _clubStream = _gameStream.switchMap((game) {
      return supabase.from('clubs').stream(primaryKey: [
        'id'
      ]).inFilter('id', [game.idClubLeft, game.idClubRight]).map((maps) => maps
          .map((map) =>
              Club.fromMap(map: map, myUserId: supabase.auth.currentUser!.id))
          .toList());
    });

    // Combine game and club streams
    _gameStream = _gameStream.switchMap((game) {
      return _clubStream.map((clubs) {
        try {
          game.leftClub =
              clubs.firstWhere((club) => game.idClubLeft == club.id_club);
          game.rightClub =
              clubs.firstWhere((club) => game.idClubRight == club.id_club);
        } catch (e) {
          // Handle the case when the club is not found
          game.leftClub = null;
          game.rightClub = null;
          print('catch error !');
        }
        return game;
      });
    });

    // Stream to fetch team comps related to the game
    _teamCompStream = _gameStream.switchMap((game) {
      final gameId = game.id;
      return supabase
          .from('games_team_comp')
          .stream(primaryKey: ['id'])
          .eq('id_game', gameId)
          .map((maps) => maps.map((map) => TeamComp.fromMap(map, {})).toList());
    });

    // Stream to fetch players related to the team comps
    _playerStream = _teamCompStream.switchMap((teamComps) {
      final playerIds = teamComps
          .expand((teamComp) => [
                teamComp.goalKeeper?.id,
                teamComp.leftBackWinger?.id,
                teamComp.leftCentralBack?.id,
                teamComp.centralBack?.id,
                teamComp.rightCentralBack?.id,
                teamComp.rightBackWinger?.id,
                teamComp.leftWinger?.id,
                teamComp.leftMidFielder?.id,
                teamComp.centralMidFielder?.id,
                teamComp.rightMidFielder?.id,
                teamComp.rightWinger?.id,
                teamComp.leftStriker?.id,
                teamComp.centralStriker?.id,
                teamComp.rightStriker?.id,
                teamComp.sub1?.id,
                teamComp.sub2?.id,
                teamComp.sub3?.id,
                teamComp.sub4?.id,
                teamComp.sub5?.id,
                teamComp.sub6?.id
              ])
          .where((id) => id != null)
          .toSet()
          .toList();

      return supabase
          .from('players')
          .stream(primaryKey: ['id'])
          .inFilter('id', playerIds.cast<Object>())
          .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
    });

    // Combine team comp and player streams
    _teamCompStream = _teamCompStream.switchMap((teamComps) {
      return _playerStream.map((players) {
        final playerMap = {for (var player in players) player.id: player};
        return teamComps
            .map((teamComp) => TeamComp.fromMap({
                  'id': teamComp.id,
                  'id_game': teamComp.idGame,
                  'id_club': teamComp.idClub,
                  'idgoalkeeper': teamComp.goalKeeper?.id,
                  'idleftbackwinger': teamComp.leftBackWinger?.id,
                  'idleftcentralback': teamComp.leftCentralBack?.id,
                  'idcentralback': teamComp.centralBack?.id,
                  'idrightcentralback': teamComp.rightCentralBack?.id,
                  'idrightbackwinger': teamComp.rightBackWinger?.id,
                  'idleftwinger': teamComp.leftWinger?.id,
                  'idleftmidfielder': teamComp.leftMidFielder?.id,
                  'idcentralmidfielder': teamComp.centralMidFielder?.id,
                  'idrightmidfielder': teamComp.rightMidFielder?.id,
                  'idrightwinger': teamComp.rightWinger?.id,
                  'idleftstriker': teamComp.leftStriker?.id,
                  'idcentralstriker': teamComp.centralStriker?.id,
                  'idrightstriker': teamComp.rightStriker?.id,
                  'idsub1': teamComp.sub1?.id,
                  'idsub2': teamComp.sub2?.id,
                  'idsub3': teamComp.sub3?.id,
                  'idsub4': teamComp.sub4?.id,
                  'idsub5': teamComp.sub5?.id,
                  'idsub6': teamComp.sub6?.id,
                }, playerMap))
            .toList();
      });
    });
    // Combine team comps with clubs in the game
    _gameStream = _gameStream.switchMap((game) {
      return _teamCompStream.map((teamComps) {
        game.leftClub!.teamcomp = teamComps
            .firstWhere((teamComp) => teamComp.idClub == game.idClubLeft);
        game.rightClub!.teamcomp = teamComps
            .firstWhere((teamComp) => teamComp.idClub == game.idClubRight);
        return game;
      });
    });

    // // Stream to fetch game events related to the game
    // _eventStream = _gameStream.switchMap((game) {
    //   final gameId = game.id;
    //   return supabase
    //       .from('game_events')
    //       .stream(primaryKey: ['id'])
    //       .eq('id_game', gameId)
    //       .map((maps) => maps.map((map) => GameEvent.fromMap(map)).toList());
    // });
    // // Combine game and event streams
    // _gameStream = _gameStream.switchMap((game) {
    //   return _eventStream.map((events) {
    //     game.events = events;
    //     return game;
    //   });
    // });

    super.initState();
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
                title: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          ClubPage.route(game.idClubLeft),
                        );
                      },
                      // child: game.getLeftClubName(),
                      child: Text('testLeft'),
                    ),
                    SizedBox(width: 6),
                    // game.isPlayed ? game.getScoreRow() : Text('VS'),
                    SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          ClubPage.route(game.idClubRight),
                        );
                      },
                      // child: game.getRightClubName(),
                      child: Text('testRight'),
                    ),
                  ],
                ),
              ),
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
                                // game.getGameDetail(context),
                                // _getGameReport(game.events, context),
                                // _getTeamsComp(events, context),
                                Column(
                                  children: [
                                    Text(game.id.toString()),
                                    Text(game.leftClub!.club_name.toString()),
                                    Text(game.rightClub!.club_name.toString()),
                                    Text(game.rightClub!.teamcomp!.id
                                        .toString()),
                                    Text(game.rightClub!.teamcomp!.idClub
                                        .toString()),
                                  ],
                                ),
                                Text('test'),
                                Text('test'),
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
