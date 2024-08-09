import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/gameUser.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:opengoalz/classes/player/player_card.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/settings_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/classes/player/players_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/multiverse_row_widget.dart';
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
  late Stream<GameUser> _userStream;
  @override
  void initState() {
    if (widget.userName != null) {
      _userStream = supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('username', widget.userName as Object)
          .map((maps) => maps.map((map) => GameUser.fromMap(map)).first)
          .switchMap((GameUser user) {
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
          .switchMap((GameUser user) {
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userName != null) {
      return StreamBuilder<GameUser>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          GameUser user = snapshot.data!;
          return _buildUserWidget(user);
        },
      );
    } else {
      return Consumer<SessionProvider>(
        builder: (context, sessionProvider, child) {
          GameUser? user = sessionProvider.user;
          return _buildUserWidget(user);
        },
      );
    }
  }

  Widget _buildUserWidget(GameUser? user) {
    if (user == null) {
      return const Center(child: Text('User not found'));
    }
    return Scaffold(
      appBar: AppBar(
        title: user.getUserName(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(SettingsPage.route());
            },
            icon: Icon(Icons.settings, size: iconSizeSmall),
          ),

          /// Button depending if the user is the currently connected user
          user.isConnectedUser
              // If the user is the connected user, show the logout button
              ? IconButton(
                  onPressed: () async {
                    bool logoutConfirmed = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Logout"),
                          content: Text("Are you sure you want to log out?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                // Dismiss the dialog and return false to indicate cancellation
                                Navigator.of(context).pop(false);
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Dismiss the dialog and return true to indicate confirmation
                                Navigator.of(context).pop(true);
                              },
                              child: Text("Logout"),
                            ),
                          ],
                        );
                      },
                    );

                    // If logout is confirmed, proceed with logout
                    if (logoutConfirmed == true) {
                      await supabase.auth.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                          LoginPage.route(), (route) => false);
                    }
                  },
                  icon: Icon(Icons.logout, size: iconSizeSmall),
                )
              // If the user is not the connected user, show the switch button
              : Provider.of<SessionProvider>(context)
                  .user!
                  .returnToConnectedUserIconButton(context)
        ],
      ),
      drawer: const AppDrawer(),
      body: MaxWidthContainer(
          child: DefaultTabController(
        length: 3, // The number of tabs
        child: Column(
          children: [
            TabBar(
              tabs: [
                buildTabWithIcon(icon_club, 'Clubs (${user.clubs.length})'),
                buildTabWithIcon(
                    icon_players, 'Players (${user.players.length})'),
                buildTabWithIcon(Icons.description, 'User'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _clubListWidget(context, user),
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

  Widget _clubListWidget(BuildContext context, GameUser user) {
    if (user.clubs.isEmpty) {
      return const Center(child: Text('No clubs found'));
    }
    return Column(
      children: [
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: user.clubs.length,
            itemBuilder: (context, index) {
              final Club club = user.clubs[index];
              return Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          24), // Adjust border radius as needed
                      side: const BorderSide(
                        color: Colors.blueGrey, // Border color
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Provider.of<SessionProvider>(context, listen: false)
                                .providerSetSelectedClub(club.id);
                          },
                          leading: CircleAvatar(
                            backgroundColor: (club.id ==
                                    Provider.of<SessionProvider>(context)
                                        .user!
                                        .selectedClub
                                        .id)
                                ? Colors.green
                                : Colors.blueGrey,
                            child: Text(
                              (index + 1).toString(),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                24), // Adjust border radius as needed
                            side: const BorderSide(
                              color: Colors.blueGrey, // Border color
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              club.getClubName(context),
                              club.getLastResultsWidget()
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              club.getRankingWidget(context),
                              multiverseWidget(club.multiverseSpeed),
                            ],
                          ),
                        ),
                        if (club.id ==
                            Provider.of<SessionProvider>(context)
                                .user!
                                .selectedClub
                                .id)
                          Column(
                            children: [
                              const SizedBox(height: 6),
                              club.getQuickAccessWidget(context, club.id),
                              const SizedBox(height: 6),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _playerListWidget(BuildContext context, GameUser user) {
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
                child: Column(
                  children: [
                    PlayerCard(
                        player: player, number: index + 1, isExpanded: false),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
