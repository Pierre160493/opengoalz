import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/subs.dart';
import 'package:opengoalz/classes/teamcomp/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:rxdart/rxdart.dart';

class TeamCompsPage extends StatefulWidget {
  final int idClub;
  final int seasonNumber;
  const TeamCompsPage(
      {Key? key, required this.idClub, required this.seasonNumber})
      : super(key: key);

  static Route<void> route(int idClub, int seasonNumber) {
    return MaterialPageRoute(
      builder: (context) => TeamCompsPage(
        idClub: idClub,
        seasonNumber: seasonNumber,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _TeamCompsPageState();
  }
}

class _TeamCompsPageState extends State<TeamCompsPage> {
  late Stream<Club> _clubStream;
  late int _seasonNumber;

  @override
  void initState() {
    super.initState();

    _seasonNumber = widget.seasonNumber; // Initialize _seasonNumber here

    _loadClubStream();
  }

  void _loadClubStream() {
    _clubStream = supabase
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idClub)
        .map((maps) => maps.map((map) => Club.fromMap(map)).first)
        .switchMap((Club club) {
          return supabase
              .from('games_teamcomp')
              .stream(primaryKey: ['id'])
              .eq('id_club', club.id)
              .map((maps) => maps.map((map) => TeamComp.fromMap(map)).toList())
              .map((List<TeamComp> teamComps) {
                /// Clear the lists otherwise when stream emits new data, the new teamcomps are appended
                club.defaultTeamComps.clear();
                club.teamComps.clear();

                /// Set all the teamComps
                for (TeamComp teamComp in teamComps
                    .where((TeamComp teamcomp) => teamcomp.seasonNumber == 0)) {
                  club.defaultTeamComps.add(teamComp);
                }

                /// Set the games teamcomps
                for (TeamComp teamComp in teamComps.where((TeamComp teamcomp) =>
                    teamcomp.seasonNumber == _seasonNumber)) {
                  club.teamComps.add(teamComp);
                }

                /// Sort
                club.defaultTeamComps
                    .sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
                club.teamComps
                    .sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
                return club;
              });
        })
        .switchMap((Club club) {
          return supabase
              .from('players')
              .stream(primaryKey: ['id'])
              .inFilter(
                  'id',
                  [
                    ...club.teamComps
                        .expand((TeamComp teamComp) =>
                            teamComp.playersIdToListOfInt())
                        .where((id) => id != null)
                        .cast<Object>(),
                    ...club.defaultTeamComps
                        .expand((TeamComp teamComp) =>
                            teamComp.playersIdToListOfInt())
                        .where((id) => id != null)
                        .cast<Object>()
                  ].toSet().toList())
              .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
              .map((players) {
                for (TeamComp teamComp
                    in club.teamComps + club.defaultTeamComps) {
                  teamComp.initPlayers(players
                      .where((player) => player.idClub == club.id)
                      .toList());
                }
                return club;
              });
        })
        .switchMap((Club club) {
          return supabase
              .from('game_orders')
              .stream(primaryKey: ['id'])
              .inFilter(
                  'id_teamcomp',
                  [
                    ...club.defaultTeamComps
                        .map((teamComp) => teamComp.id)
                        .toList(),
                    ...club.teamComps.map((teamComp) => teamComp.id).toList(),
                  ].toSet().toList())
              .order('minute', ascending: true)
              .map((maps) => maps.map((map) => GameSub.fromMap(map)).toList())
              .map((subs) {
                for (TeamComp teamComp
                    in club.teamComps + club.defaultTeamComps) {
                  teamComp.subs = subs
                      .where((sub) => sub.idTeamComp == teamComp.id)
                      .toList();
                }
                return club;
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Club>(
        stream: _clubStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('ERROR: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No data available'),
            );
          } else {
            Club club = snapshot.data!;

            return Scaffold(
              appBar: AppBar(
                title: Text('TeamComps for season ${_seasonNumber}'),
                actions: [
                  if (_seasonNumber > 1)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _seasonNumber -=
                              1; // Modify the state variable instead of the widget property
                        });
                      },
                      icon: Icon(Icons.arrow_circle_left, size: iconSizeSmall),
                    ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _seasonNumber +=
                            1; // Modify the state variable instead of the widget property
                      });
                    },
                    icon: Icon(Icons.arrow_circle_right, size: iconSizeSmall),
                  ),
                ],
              ), //Row presentation of the game

              body: MaxWidthContainer(
                child: DefaultTabController(
                  length: 2, // Number of tabs for the outer TabController
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          buildTabWithIcon(Icons.save, 'Defaults'),
                          buildTabWithIcon(
                              Icons.update, 'Season ${_seasonNumber}'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            DefaultTabController(
                              length: club.defaultTeamComps
                                  .length, // Number of tabs for the outer TabController
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TabBar(
                                    isScrollable: true,
                                    tabs: [
                                      ...List<Widget>.generate(
                                        club.defaultTeamComps.length,
                                        (index) => buildTabWithIcon(
                                            Icons.save,
                                            // '${index + 1}: Default'),
                                            club.defaultTeamComps[index].name),
                                      ),
                                      // IconButton(
                                      //   icon: Icon(Icons.add),
                                      //   onPressed: () async {
                                      //     try {
                                      //       var response = await supabase
                                      //           .from('games_teamcomp')
                                      //           .insert({
                                      //         'id_club': club.id,
                                      //         'season_number': 0,
                                      //         'week_number':
                                      //             club.defaultTeamComps.length +
                                      //                 1,
                                      //       });

                                      //       if (response.error != null) {
                                      //         ScaffoldMessenger.of(context)
                                      //             .showSnackBar(
                                      //           SnackBar(
                                      //             content: Text(
                                      //                 'Insert failed: ${response.error.message}'),
                                      //             backgroundColor: Colors.red,
                                      //           ),
                                      //         );
                                      //       } else {
                                      //         ScaffoldMessenger.of(context)
                                      //             .showSnackBar(
                                      //           SnackBar(
                                      //             content: Text(
                                      //                 'Inserted successfully'),
                                      //             backgroundColor: Colors.green,
                                      //           ),
                                      //         );
                                      //       }
                                      //     } catch (e) {
                                      //       ScaffoldMessenger.of(context)
                                      //           .showSnackBar(
                                      //         SnackBar(
                                      //           content: Text(
                                      //               'An error occurred: $e'),
                                      //           backgroundColor: Colors.red,
                                      //         ),
                                      //       );
                                      //     }
                                      //   },
                                      // ),
                                    ],
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: List<Widget>.generate(
                                        club.defaultTeamComps.length,
                                        (index) => club.defaultTeamComps[index]
                                            .getMainTeamCompWidget(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DefaultTabController(
                              length: club.teamComps
                                  .length, // Number of tabs for the outer TabController
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TabBar(
                                    isScrollable: true,
                                    tabs: List<Widget>.generate(
                                      club.teamComps.length,
                                      (index) => Tab(text: '${index + 1}'),
                                    ),
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: List<Widget>.generate(
                                        14,
                                        (index) => club.teamComps[index]
                                            .getMainTeamCompWidget(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
