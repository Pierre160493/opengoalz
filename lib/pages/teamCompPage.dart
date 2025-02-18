import 'package:flutter/material.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/teamcomp/teamCompTab.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class TeamCompPage extends StatefulWidget {
  final int? idClub;
  final int? seasonNumber;
  final int? weekNumber;
  final int? id;

  const TeamCompPage({
    Key? key,
    this.idClub,
    this.seasonNumber,
    this.weekNumber,
    this.id,
  }) : super(key: key);

  TeamCompPage.withId({
    Key? key,
    required this.id,
  })  : idClub = null,
        seasonNumber = null,
        weekNumber = null,
        super(key: key);

  TeamCompPage.withDetails({
    Key? key,
    required this.idClub,
    required this.seasonNumber,
    required this.weekNumber,
  })  : id = null,
        super(key: key);

  static Route<void> routeWithId(int id) {
    return MaterialPageRoute(
      builder: (context) => TeamCompPage.withId(id: id),
    );
  }

  static Route<void> routeWithDetails(
      int idClub, int seasonNumber, int weekNumber) {
    return MaterialPageRoute(
      builder: (context) => TeamCompPage.withDetails(
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

    if (widget.id != null) {
      _clubStream = supabase
          .from('clubs')
          .stream(primaryKey: ['id'])
          .eq('id', widget.id!)
          .map((maps) => maps.map((map) => Club.fromMap(map)).first);
    } else if (widget.idClub != null &&
        widget.seasonNumber != null &&
        widget.weekNumber != null) {
      _clubStream = supabase
          .from('clubs')
          .stream(primaryKey: ['id'])
          .eq('id', widget.idClub!)
          .map((maps) => maps.map((map) => Club.fromMap(map)).first)
          .switchMap((Club club) {
            return supabase
                .from('games_teamcomp')
                .stream(primaryKey: ['id'])
                .eq('id_club', club.id)
                .map(
                    (maps) => maps.map((map) => TeamComp.fromMap(map)).toList())
                .map((teamComps) {
                  for (TeamComp teamComp in teamComps.where(
                      (TeamComp teamcomp) =>
                          teamcomp.seasonNumber == widget.seasonNumber &&
                          teamcomp.weekNumber == widget.weekNumber)) {
                    club.teamComps.clear();
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
                .map((maps) => maps
                    .map((map) => Player.fromMap(
                        map,
                        Provider.of<UserSessionProvider>(context, listen: false)
                            .user))
                    .toList())
                .map((players) {
                  club.teamComps.first.initPlayers(players
                      .where((player) => player.idClub == club.id)
                      .toList());

                  return club;
                });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Club>(
        stream: _clubStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCircularAndText('Loading team comp...');
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
                    'TeamComp for ${club.name} for week ${club.teamComps.first.weekNumber} of season ${club.teamComps.first.seasonNumber}'),
                leading: goBackIconButton(context),
              ), //Row presentation of the game
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
                              // club.teamComps.first.getTeamCompWidget(context),
                              TeamCompTab(
                                club: club,
                              ),
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
