import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/pages/mails_page.dart';
import 'package:opengoalz/pages/settings_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/sendMail.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:opengoalz/widgets/userPageListOfClubsAndPlayers.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class UserPage extends StatefulWidget {
  final String? userName;
  const UserPage({Key? key, this.userName}) : super(key: key);

  static Route<void> route({String? userName}) {
    return MaterialPageRoute(
      builder: (context) => UserPage(userName: userName),
    );
  }

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Stream<Profile> _userStream;

  @override
  void initState() {
    super.initState();
    if (widget.userName != null) {
      _userStream = supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('username', widget.userName as Object)
          .map((maps) => maps.map((map) => Profile.fromMap(map)).first)
          .switchMap((Profile user) {
            return supabase
                .from('clubs')
                .stream(primaryKey: ['id'])
                .eq('username', user.username)
                .order('user_since')
                .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
                .map((List<Club> clubs) {
                  user.clubs = clubs;
                  return user;
                });
          })
          .switchMap((Profile user) {
            return supabase
                .from('players')
                .stream(primaryKey: ['id'])
                .eq('username', user.username)
                .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
                .map((List<Player> players) {
                  user.players = players;
                  return user;
                });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userName != null) {
      return StreamBuilder<Profile>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('User not found'));
          }
          Profile user = snapshot.data!;
          return _buildUserWidget(user);
        },
      );
    } else {
      return Consumer<SessionProvider>(
        builder: (context, sessionProvider, child) {
          Profile? user = sessionProvider.user;
          print('User: $user');
          return _buildUserWidget(user);
        },
      );
    }
  }

  Widget _buildUserWidget(Profile? user) {
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('User not found, please try again'),
            formSpacer12,
            ElevatedButton(
              onPressed: () async {
                await supabase.auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  LoginPage.route(),
                  (route) => false,
                );
              },
              child: const Text('Reset App'),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: user.getUserName(context),
        actions: [
          Tooltip(
            message: 'Open Settings Page',
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(SettingsPage.route());
              },
              icon: Icon(Icons.settings, size: iconSizeSmall),
            ),
          ),
          user.isConnectedUser
              ? Tooltip(
                  message: 'Open Mails Page',
                  child: IconButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MailsPage(idClub: user.selectedClub!.id)),
                      );
                    },
                    icon: Icon(Icons.mail, size: iconSizeSmall),
                  ),
                )
              : Tooltip(
                  message: 'Send Mail',
                  child: IconButton(
                    onPressed: () async {
                      sendMailDialog(context,
                          idClub: user.selectedClub!.id,
                          username: user.username);
                    },
                    icon: Icon(Icons.quick_contacts_mail, size: iconSizeSmall),
                  ),
                ),
          user.isConnectedUser
              ? Tooltip(
                  message: 'Logout',
                  child: IconButton(
                    onPressed: () async {
                      bool logoutConfirmed =
                          await context.showConfirmationDialog(
                              'Are you sure you want to log out?');
                      if (logoutConfirmed == true) {
                        await supabase.auth.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                            LoginPage.route(), (route) => false);
                      }
                    },
                    icon: Icon(Icons.logout, size: iconSizeSmall),
                  ),
                )
              : Provider.of<SessionProvider>(context, listen: false)
                  .user!
                  .returnToConnectedUserIconButton(context),
        ],
      ),
      drawer: const AppDrawer(),
      body: MaxWidthContainer(
          child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                buildTabWithIcon(
                    icon_club,
                    user.clubs.length == 0
                        ? 'No club yet'
                        : user.clubs.length == 1
                            ? '1 Club'
                            : '${user.clubs.length} clubs'),
                buildTabWithIcon(
                    icon_players,
                    user.players.length == 0
                        ? 'No player yet'
                        : user.players.length == 1
                            ? '1 player'
                            : '${user.players.length} players'),
                buildTabWithIcon(Icons.description, 'User'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  clubListWidget(context, user),
                  playerListWidget(context, user),
                  Column(
                    children: [
                      formSpacer6,
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              24), // Adjust border radius as needed
                          side: const BorderSide(
                            color: Colors.blueGrey, // Border color
                          ),
                        ),
                        leading: Icon(
                          iconUser,
                        ),
                        title: Text('Username: ${user.username}'),
                        subtitle: Row(
                          children: [
                            Icon(Icons.timer),
                            Text(
                              'Since: ${DateFormat.yMMMMd('en_US').format(user.createdAt)}',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Club tile
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              24), // Adjust border radius as needed
                          side: BorderSide(
                            color: user.numberClubsAvailable > user.clubs.length
                                ? Colors.green
                                : Colors.blueGrey, // Border color
                          ),
                        ),
                        leading: Icon(
                          icon_club,
                        ),
                        title: Text(
                            'Number of Club${user.clubs.length > 1 ? 's' : ''}: ${user.clubs.length}/${user.numberClubsAvailable}'),
                        subtitle: Text(
                          'Number of clubs / number of available clubs',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        onTap: () {
                          /// If the user has less clubs than the number of clubs available, show the dialog
                          if (user.numberClubsAvailable > user.clubs.length) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AssignPlayerOrClubDialog(isClub: true);
                              },
                            );
                          } else {
                            context.showSnackBarError(
                                'You cannot have any additional club');
                          }
                        },
                      ),

                      /// Player tile
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              24), // Adjust border radius as needed
                          side: BorderSide(
                            color: user.numberPlayersAvailable >
                                    user.players.length
                                ? Colors.green
                                : Colors.blueGrey, // Border color
                          ),
                        ),
                        leading: Icon(
                          icon_players,
                        ),
                        title: Text(
                            'Number of Player${user.players.length > 1 ? 's' : ''}: ${user.players.length}/${user.numberPlayersAvailable}'),
                        subtitle: Text(
                          'Number of players / number of available players',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        onTap: () {
                          /// If the user has less clubs than the number of clubs available, show the dialog
                          if (user.numberPlayersAvailable >
                              user.players.length) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AssignPlayerOrClubDialog(isClub: false);
                              },
                            );
                          } else {
                            context.showSnackBarError(
                                'You cannot have any additional player');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  // Widget _playerListWidget(BuildContext context, Profile user) {
  //   if (user.players.isEmpty) {
  //     return ListTile(
  //     leading: const Icon(Icons.cancel, color: Colors.red),
  //     title: const Text('You dont have any club yet'),
  //     subtitle: const Text(
  //         'Create a club to start your aventure and show your skills !',
  //         style:
  //             TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic)),
  //     trailing: IconButton(
  //       tooltip: 'Get a club',
  //       icon: const Icon(
  //         Icons.add,
  //         color: Colors.green,
  //       ),
  //       onPressed: () {
  //         _assignPlayer(context);
  //       },
  //     ),
  //   );
  //   }
  //   return Column(
  //     children: [
  //       const SizedBox(height: 12),
  //       Expanded(
  //         child: ListView.builder(
  //           itemCount: user.players.length,
  //           itemBuilder: (context, index) {
  //             final Player player = user.players[index];
  //             return InkWell(
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => PlayersPage(
  //                       inputCriteria: {
  //                         'id_player': [player.id]
  //                       },
  //                     ),
  //                   ),
  //                 );
  //               },
  //               child: PlayerCard(
  //                   player: player,
  //                   index: user.players.length == 1 ? 0 : index + 1,
  //                   isExpanded: user.players.length == 1 ? true : false),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
