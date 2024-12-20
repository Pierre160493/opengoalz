import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:rxdart/rxdart.dart';

class TeamCompPage extends StatefulWidget {
  final int idClub;
  final int seasonNumber;
  final int weekNumber;
  const TeamCompPage(
      {Key? key,
      required this.idClub,
      required this.seasonNumber,
      required this.weekNumber})
      : super(key: key);

  static Route<void> route(int idClub, int seasonNumber, int weekNumber) {
    return MaterialPageRoute(
      builder: (context) => TeamCompPage(
          idClub: idClub, seasonNumber: seasonNumber, weekNumber: weekNumber),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _TeamCompPageState();
  }
}

class _TeamCompPageState extends State<TeamCompPage> {
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
              .map((teamComps) {
                for (TeamComp teamComp in teamComps.where((TeamComp teamcomp) =>
                    teamcomp.seasonNumber == widget.seasonNumber &&
                    teamcomp.weekNumber == widget.weekNumber)) {
                  club.teamComps
                      .clear(); // Clear otherwise it appends the new element to the list when stream emits new data
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
                    .playersIdToListOfInt()
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
                      'TeamComp for ${club.name} for week ${club.teamComps.first.weekNumber} of season ${club.teamComps.first.seasonNumber}')), //Row presentation of the game
              body: MaxWidthContainer(
                child: DefaultTabController(
                    length: 3, // Number of tabs
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabBar(
                          tabs: [
                            buildTab(Icons.preview, 'TeamComp'),
                            buildTab(Icons.reviews, 'Stats'),
                            buildTab(Icons.group, 'Teams'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              club.teamComps.first.getTeamCompWidget(context),
                              Center(child: Text('test')),
                              Center(child: Text('test')),
                            ],
                          ),
                        ),
                      ],
                    )),
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
