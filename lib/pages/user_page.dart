import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/pages/settings_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/models/mails/mailsWidget.dart';
import 'package:opengoalz/widgets/creationDialogBox_Club.dart';
import 'package:opengoalz/widgets/creationDialogBox_Player.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/sendMail.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:opengoalz/widgets/userPageListOfClubs.dart';
import 'package:opengoalz/widgets/userPageListOfPlayers.dart';
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
      final connectedUser =
          Provider.of<UserSessionProvider>(context, listen: false).user;
      if (widget.userName == connectedUser.username) {
        // Use the data from the provider if the username matches the connected user
        _userStream = Stream.value(connectedUser);
      } else {
        // Fetch the data from the database if the username does not match the connected user
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
                  .map((maps) =>
                      maps.map((map) => Player.fromMap(map, user)).toList())
                  .map((List<Player> players) {
                    user.playersIncarnated = players;
                    return user;
                  });
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userName != null) {
      return StreamBuilder<Profile>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCircularAndText('Loading user...');
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
      return Consumer<UserSessionProvider>(
        builder: (context, UserSessionProvider, child) {
          Profile? user = UserSessionProvider.user;
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
              icon: Icon(Icons.settings,
                  size: iconSizeMedium, color: Colors.green),
            ),
          ),

          /// Reload pae button
          Tooltip(
            message: 'Reload page',
            child: IconButton(
              onPressed: () async {
                // Refetch the user
                await Provider.of<UserSessionProvider>(context, listen: false)
                    .providerFetchUser(context,
                        userId: supabase.auth.currentUser!.id);
// Reload the UserPage
                Navigator.of(context)
                    .pushAndRemoveUntil(UserPage.route(), (route) => false);
                context.showSnackBarSuccess('User and Page reloaded');
              },
              icon: Icon(Icons.refresh,
                  size: iconSizeMedium, color: Colors.green),
            ),
          ),
          user.isConnectedUser
              ? mailToolTip(context, user)
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
                    icon: Icon(Icons.logout,
                        size: iconSizeSmall, color: Colors.red),
                  ),
                )
              : Provider.of<UserSessionProvider>(context, listen: false)
                  .user
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
                    icon: iconClub,
                    text: user.clubs.length == 0
                        ? 'No club'
                        : user.clubs.length == 1
                            ? '1 Club'
                            : '${user.clubs.length} clubs',
                    iconColor:
                        user.clubs.length == 0 ? Colors.red : Colors.green),
                buildTabWithIcon(
                    icon: iconPlayers,
                    text: user.playersIncarnated.length == 0
                        ? 'No player'
                        : user.playersIncarnated.length == 1
                            ? '1 player'
                            : '${user.playersIncarnated.length} players',
                    iconColor: user.playersIncarnated.length == 0
                        ? Colors.red
                        : Colors.green),
                buildTabWithIcon(icon: Icons.description, text: 'User'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  userClubListWidget(context, user),
                  userPlayerListWidget(context, user),
                  _getUserWidget(user),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _getUserWidget(Profile user) {
    bool canCreateClub = user.numberClubsAvailable > user.clubs.length;
    bool canCreatePlayer =
        user.numberPlayersAvailable > user.playersIncarnated.length;
    return Column(
      children: [
        ListTile(
          shape: shapePersoRoundedBorder(),
          leading: Icon(
            iconUser,
            color: Colors.green,
            size: iconSizeMedium,
          ),
          title: Text('Username: ${user.username}'),
          subtitle: Row(
            children: [
              Icon(
                Icons.timer,
                size: iconSizeSmall,
                color: Colors.green,
              ),
              Text(
                'Since: ${DateFormat.yMMMMd('en_US').format(user.createdAt)}',
                style: styleItalicBlueGrey,
              ),
            ],
          ),
        ),

        /// Credits tile
        ListTile(
          shape: shapePersoRoundedBorder(),
          leading: Icon(
            iconCredits,
            color: Colors.green,
            size: iconSizeMedium,
          ),
          title: Text('Credits: ${user.creditsAvailable}'),
          subtitle: const Text('Available credits', style: styleItalicBlueGrey),
        ),

        /// Club tile
        ListTile(
          shape: shapePersoRoundedBorder(
              canCreateClub ? Colors.green : Colors.orange),
          leading: Icon(
            iconClub,
            color: canCreateClub ? Colors.green : Colors.orange,
            size: iconSizeMedium,
          ),
          title: Text(
              'Number of Club${user.clubs.length > 1 ? 's' : ''}: ${user.clubs.length} / ${user.numberClubsAvailable}'),
          subtitle: Text(
              canCreateClub
                  ? 'You can ceate ${user.numberClubsAvailable - user.clubs.length} additional club${user.numberClubsAvailable - user.clubs.length > 1 ? 's' : ''}'
                  : 'You cannot have any additional club',
              style: styleItalicBlueGrey),
          onTap: canCreateClub
              ? () {
                  /// If the user has less clubs than the number of clubs available, show the dialog
                  if (user.numberClubsAvailable > user.clubs.length) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CreationDialogBox_Club();
                      },
                    );
                  }
                }
              : null,
        ),

        /// Player tile
        ListTile(
            shape: shapePersoRoundedBorder(
                canCreatePlayer ? Colors.green : Colors.orange),
            leading: Icon(
              iconPlayers,
              color: canCreatePlayer ? Colors.green : Colors.orange,
              size: iconSizeMedium,
            ),
            title: Text(
                'Number of Player${user.playersIncarnated.length > 1 ? 's' : ''}: ${user.playersIncarnated.length} / ${user.numberPlayersAvailable}'),
            subtitle: Text(
              canCreatePlayer
                  ? 'You can ceate ${user.numberPlayersAvailable - user.playersIncarnated.length} additional player${user.numberPlayersAvailable - user.playersIncarnated.length > 1 ? 's' : ''}'
                  : 'You cannot have any additional player',
              style: styleItalicBlueGrey,
            ),
            onTap: canCreatePlayer
                ? () {
                    /// If the user has less clubs than the number of players available, show the dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CreationDialogBox_Player();
                      },
                    );
                  }
                : null),
      ],
    );
  }
}
