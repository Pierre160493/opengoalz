import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/clubCashListTile.dart';
import 'package:opengoalz/models/multiverse/multiverseWidgets.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/pages/league_page.dart';
import 'package:opengoalz/pages/user_page.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_theme_app.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/countryListTile.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ClubPage extends StatefulWidget {
  final int idClub;
  const ClubPage({Key? key, required this.idClub}) : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute(
      builder: (context) => ClubPage(idClub: idClub),
    );
  }

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  late Stream<Club> _clubStream;

  @override
  void initState() {
    super.initState();

    _clubStream = supabase

        /// Fetch the club
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idClub)
        .map((maps) => maps.map((map) => Club.fromMap(map)).first)

        /// Fetch its league
        .switchMap((Club club) {
          return supabase
              .from('leagues')
              .stream(primaryKey: ['id'])
              .eq('id', club.idLeague)
              .map((maps) => maps.map((map) => League.fromMap(map)).first)
              .map((League league) {
                club.league = league;
                return club;
              });
        })

        /// Fetch its players
        .switchMap((Club club) {
          return supabase
              .from('players')
              .stream(primaryKey: ['id'])
              .eq('id_club', club.id)
              .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
              .map((players) {
                club.players = players;
                return club;
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Club>(
      stream: _clubStream,
      builder: (context, AsyncSnapshot<Club> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error occurred: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else {
          Club club = snapshot.data!;
          bool isSelectedClub =
              Provider.of<SessionProvider>(context).user?.selectedClub!.id ==
                  club.id;
          return Scaffold(
            appBar: AppBar(
              title: club.getClubName(context),
              actions: [
                goBackIconButton(context),
              ],
            ),
            drawer: const AppDrawer(),
            body: MaxWidthContainer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                    leading: Icon(
                      icon_club,
                      size: 48,
                      color: isSelectedClub ? colorIsSelected : Colors.green,
                    ), // Icon to indicate club
                    title: InkWell(
                      onTap: () {
                        isSelectedClub
                            ? showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  String inputText = '';
                                  return AlertDialog(
                                    title: const Text('Change Club Name'),
                                    content: TextField(
                                      onChanged: (value) {
                                        inputText = value;
                                      },
                                      decoration: const InputDecoration(
                                          hintText: "Enter the new club name"),
                                    ),
                                    actions: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            child: persoCancelRow,
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(iconSuccessfulOperation,
                                                    color: Colors.green),
                                                formSpacer3,
                                                const Text('Submit'),
                                              ],
                                            ),
                                            onPressed: () async {
                                              bool isOK = await operationInDB(
                                                  context, 'UPDATE', 'clubs',
                                                  data: {
                                                    'name': inputText
                                                  },
                                                  matchCriteria: {
                                                    'id': club.id
                                                  });

                                              if (isOK) {
                                                context.showSnackBarSuccess(
                                                    'Successfully updated the club name to $inputText');
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              }
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              )
                            : null;
                      },
                      child: Text(
                        club.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24, // Increase the font size as needed
                        ),
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          'Creation Date: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${DateFormat.yMMMMd('en_US').format(club.createdAt)}',
                        ),
                      ],
                    ),
                  ),
                  formSpacer6,

                  /// Username of the club owner
                  ListTile(
                      shape: shapePersoRoundedBorder(),
                      title: getUserName(context, userName: club.userName),
                      subtitle: club.userSince == null
                          ? null
                          : Text(
                              'Club Owner Since: ' +
                                  DateFormat.yMMMMd('en_US')
                                      .format(club.userSince!),
                              style: styleItalicBlueGrey),
                      onTap: () async => {
                            /// Reset the user to the user that is being visited
                            await Provider.of<SessionProvider>(context,
                                    listen: false)
                                .providerFetchUser(context,
                                    userName: club.userName),

                            /// Modify the app theme if the user is not the connected user
                            Provider.of<ThemeProvider>(context, listen: false)
                                .setOtherThemeWhenSelectedUserIsNotConnectedUser(
                                    Provider.of<SessionProvider>(context,
                                                listen: false)
                                            .user
                                            ?.isConnectedUser ??
                                        false),

                            /// Go to the User's Page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserPage(
                                    // userName: club.userName,
                                    ),
                              ),
                            ),
                          }),
                  formSpacer6,

                  /// Multiverse
                  getMultiverseListTileFromId(context, club.idMultiverse),
                  formSpacer6,

                  /// Players
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayersPage(
                            playerSearchCriterias:
                                PlayerSearchCriterias(idClub: [club.id]),
                          ),
                        ),
                      );
                    },
                    shape: shapePersoRoundedBorder(),
                    leading: const Icon(
                      Icons.people,
                      size: 30,
                      color: Colors.green,
                    ), // Icon to indicate players
                    title: Text(
                      'Number of players: ${club.players.length}',
                    ),
                  ),
                  formSpacer6,

                  /// League
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaguePage(
                            idLeague: club.idLeague,
                          ),
                        ),
                      );
                    },
                    shape: shapePersoRoundedBorder(),
                    leading: const Icon(
                      icon_league,
                      size: 30,
                      color: Colors.green,
                    ), // Icon to indicate players
                    title: club.league == null
                        ? Text('League Not Found')
                        : club.league!.getLeagueName(),
                  ),
                  formSpacer6,

                  /// Country
                  getCountryListTile(context, club.idCountry),
                  formSpacer6,

                  /// Finances
                  getClubCashListTile(context, club),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
