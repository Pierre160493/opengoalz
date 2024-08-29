import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/profile.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:opengoalz/classes/player/player_card.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/pages/mails_page.dart';
import 'package:opengoalz/pages/settings_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/classes/player/players_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/sendMail.dart';
import 'package:opengoalz/widgets/userListOfClubsWidget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
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
              : Provider.of<SessionProvider>(context)
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
                  _playerListWidget(context, user),
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      Text('Username: ${user.username}'),
                      Text(
                          'Since: ${DateFormat.yMMMMd('en_US').format(user.createdAt)}'),
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

  Widget _playerListWidget(BuildContext context, Profile user) {
    if (user.players.isEmpty) {
      return const Center(child: Text('No players found'));
    }
    return Column(
      children: [
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: user.players.length,
            itemBuilder: (context, index) {
              final Player player = user.players[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayersPage(
                        inputCriteria: {
                          'Players': [player.id]
                        },
                      ),
                    ),
                  );
                },
                child: PlayerCard(
                    player: player,
                    index: user.players.length == 1 ? 0 : index + 1,
                    isExpanded: user.players.length == 1 ? true : false),
              );
            },
          ),
        ),
      ],
    );
  }
}
