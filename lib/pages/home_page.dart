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

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => UserPage(),
    );
  }

  @override
  State<UserPage> createState() => _HomePageState();
}

class _HomePageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, child) {
        GameUser? user = sessionProvider.user;
        return Scaffold(
          appBar: AppBar(
            title: Text(
                'Hello ${Provider.of<SessionProvider>(context).user!.username} !'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(SettingsPage.route());
                },
                icon: Icon(Icons.settings, size: iconSizeSmall),
              ),
              IconButton(
                onPressed: () async {
                  // Show confirmation dialog
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
              ),
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
                    buildTabWithIcon(
                        icon_club, 'Clubs (${user!.clubs.length})'),
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
      },
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
                          title: club.getClubName(context),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              club.getCreationWidget(),
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
                              club.getQquickAccessWidget(context),
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
