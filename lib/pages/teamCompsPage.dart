import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
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

  @override
  void initState() {
    super.initState();

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
                /// Set the default teamComps
                for (TeamComp teamComp in teamComps
                    .where((TeamComp teamcomp) => teamcomp.seasonNumber == 0)) {
                  club.defaultTeamComps.add(teamComp);
                }

                /// Set the games teamcomps
                for (TeamComp teamComp in teamComps.where((TeamComp teamcomp) =>
                    teamcomp.seasonNumber == widget.seasonNumber)) {
                  club.teamComps.add(teamComp);
                }
                return club;
              });
        })
        .switchMap((Club club) {
          return supabase
              .from('players')
              .stream(primaryKey: ['id'])
              .inFilter('id', [
                ...club.teamComps.first
                    .toListOfInt()
                    .where((id) => id != null)
                    .cast<int>()
              ])
              .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
              .map((players) {
                club.teamComps.first.initPlayers(players
                    .where((player) => player.idClub == club.id)
                    .toList());

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
                  title: Text(
                      'TeamComps for ${club.name} for season ${widget.seasonNumber}')), //Row presentation of the game
              body: MaxWidthContainer(
                child: DefaultTabController(
                  length: 2, // Number of tabs for the outer TabController
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          buildTab(Icons.save, 'Default'),
                          buildTab(Icons.update, 'This Season Games'),
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
                                    tabs: List<Widget>.generate(
                                      club.defaultTeamComps.length,
                                      (index) => Tab(text: '${index + 1}'),
                                    ),
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: List<Widget>.generate(
                                        club.defaultTeamComps.length,
                                        (index) => DefaultTabController(
                                          length:
                                              3, // Number of tabs for the inner TabController
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TabBar(
                                                tabs: [
                                                  buildTab(Icons.preview,
                                                      'TeamComp'),
                                                  buildTab(
                                                      Icons.reviews, 'Stats'),
                                                  buildTab(
                                                      Icons.group, 'Teams'),
                                                ],
                                              ),
                                              Expanded(
                                                child: TabBarView(
                                                  children: [
                                                    club.getTeamComp(
                                                        context, 0),
                                                    Center(child: Text('test')),
                                                    Center(child: Text('test')),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DefaultTabController(
                              length:
                                  14, // Number of tabs for the outer TabController
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TabBar(
                                    isScrollable: true,
                                    tabs: List<Widget>.generate(
                                      14,
                                      (index) => Tab(text: '${index + 1}'),
                                    ),
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: List<Widget>.generate(
                                        14,
                                        (index) => DefaultTabController(
                                          length:
                                              3, // Number of tabs for the inner TabController
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TabBar(
                                                tabs: [
                                                  buildTab(Icons.preview,
                                                      'TeamComp'),
                                                  buildTab(
                                                      Icons.reviews, 'Stats'),
                                                  buildTab(
                                                      Icons.group, 'Teams'),
                                                ],
                                              ),
                                              Expanded(
                                                child: TabBarView(
                                                  children: [
                                                    club.getTeamComp(
                                                        context, 0),
                                                    Center(child: Text('test')),
                                                    Center(child: Text('test')),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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

  Widget buildTab(IconData icon, String text) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(width: 6), // Add some spacing between the icon and text
          Text(text),
        ],
      ),
    );
  }
}
