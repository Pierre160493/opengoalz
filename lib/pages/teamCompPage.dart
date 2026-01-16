import 'package:flutter/material.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/teamcomp/teamCompMainTab.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/goBack_tool_tip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../models/club/class/club_widgets.dart';

class TeamCompPage extends StatefulWidget {
  final int? idClub;
  final int? seasonNumber;
  final int? weekNumber;
  final int? idTeamcomp;

  const TeamCompPage._({
    Key? key,
    this.idClub,
    this.seasonNumber,
    this.weekNumber,
    this.idTeamcomp,
  }) : super(key: key);

  factory TeamCompPage.withId({
    Key? key,
    required int idTeamcomp,
  }) {
    return TeamCompPage._(
      key: key,
      idTeamcomp: idTeamcomp,
    );
  }

  factory TeamCompPage.withDetails({
    Key? key,
    required int idClub,
    required int seasonNumber,
    required int weekNumber,
  }) {
    return TeamCompPage._(
      key: key,
      idClub: idClub,
      seasonNumber: seasonNumber,
      weekNumber: weekNumber,
    );
  }

  static Route<void> routeWithId(int idTeamcomp) {
    return MaterialPageRoute(
      builder: (context) => TeamCompPage.withId(idTeamcomp: idTeamcomp),
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
  late Profile _user;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<UserSessionProvider>(context, listen: false).user;

    if (widget.idTeamcomp != null) {
      _clubStream = _getClubStreamByTeamComp(widget.idTeamcomp!);
    } else if (widget.idClub != null &&
        widget.seasonNumber != null &&
        widget.weekNumber != null) {
      _clubStream = _getClubStreamByDetails(
          widget.idClub!, widget.seasonNumber!, widget.weekNumber!);
    } else {
      throw Exception('Invalid input parameters');
    }
  }

  Stream<Club> _getClubStreamByTeamComp(int idTeamcomp) {
    return supabase
        .from('games_teamcomp')
        .stream(primaryKey: ['id'])
        .eq('id', idTeamcomp)
        .map((maps) => maps.map((map) => TeamComp.fromMap(map)).first)
        .switchMap((TeamComp teamcomp) {
          return _getClubStream(teamcomp.idClub).map((club) {
            club.selectedTeamComp = teamcomp;
            return club;
          });
        })
        .switchMap(_getPlayersStream);
  }

  Stream<Club> _getClubStreamByDetails(
      int idClub, int seasonNumber, int weekNumber) {
    return _getClubStream(idClub).switchMap((club) {
      return supabase
          .from('games_teamcomp')
          .stream(primaryKey: ['id'])
          .eq('id_club', club.id)
          .map((maps) => maps.map((map) => TeamComp.fromMap(map)).toList())
          .map((teamComps) {
            for (TeamComp teamComp in teamComps.where((teamcomp) =>
                teamcomp.seasonNumber == seasonNumber &&
                teamcomp.weekNumber == weekNumber)) {
              club.selectedTeamComp = teamComp;
            }
            return club;
          });
    }).switchMap(_getPlayersStream);
  }

  Stream<Club> _getClubStream(int idClub) {
    return supabase
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', idClub)
        .map((maps) => maps
            .map((map) => Club.fromMap(map,
                Provider.of<UserSessionProvider>(context, listen: false).user))
            .first);
  }

  Stream<Club> _getPlayersStream(Club club) {
    return supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .inFilter('id', [
          ...club.selectedTeamComp!
              .playersIdToListOfInt()
              .where((id) => id != null)
              .cast<int>()
        ])
        .map((maps) => maps.map((map) => Player.fromMap(map, _user)).toList())
        .map((players) {
          club.selectedTeamComp!.initPlayers(
              players.where((player) => player.idClub == club.id).toList());
          return club;
        });
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
              child: Text('ERROR: ${snapshot.error}',
                  style: TextStyle(fontSize: fontSizeMedium)),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No data available',
                  style: TextStyle(fontSize: fontSizeMedium)),
            );
          } else {
            Club club = snapshot.data!;

            if (club.selectedTeamComp == null) {
              return Center(
                child: Text('No team comp found',
                    style: TextStyle(fontSize: fontSizeMedium)),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    getClubNameClickable(context,club),
                    Text(
                        ' TeamComp (Week ${club.selectedTeamComp!.weekNumber} of Season ${club.selectedTeamComp!.seasonNumber})',
                        style: TextStyle(fontSize: fontSizeLarge)),
                  ],
                ),
                leading: goBackIconButton(context),
              ),
              body: MaxWidthContainer(
                  child:
                      TeamCompMainTab(context, _user, club.selectedTeamComp)),
            );
          }
        });
  }
}
