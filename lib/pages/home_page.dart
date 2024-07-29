import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/gameUser.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/provider_global_variable.dart';
import 'package:opengoalz/pages/games_page.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/pages/league_page.dart';
import 'package:opengoalz/pages/transfer_page.dart';
import 'package:opengoalz/classes/player/players_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => HomePage(),
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            title: Text('Home Page'),
            backgroundColor: Colors.green,
            actions: [
              IconButton(
                onPressed: () {
                  // Add your action here
                },
                icon: Icon(Icons.settings),
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
                icon: Icon(Icons.logout),
              ),
            ],
          ),
          drawer: const AppDrawer(),
          body: MaxWidthContainer(
            child: user!.clubs.isEmpty
                ? const Center(child: Text('No clubs found'))
                : Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.waving_hand,
                              size: 36, color: Colors.green),
                          Text(
                            ' Hello ${Provider.of<SessionProvider>(context).user!.username} !',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Here is the list of your clubs:',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: user.clubs.length,
                          itemBuilder: (context, index) {
                            final club = user.clubs[index];
                            return Column(
                              children: [
                                Container(
                                  // margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors
                                          .blueGrey, // Change the color to whatever you want
                                      width:
                                          2, // Change the width of the border to whatever you want
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          Provider.of<SessionProvider>(context,
                                                  listen: false)
                                              .providerSetSelectedClub(club.id);
                                        },
                                        leading: CircleAvatar(
                                          backgroundColor: (club.id ==
                                                  Provider.of<SessionProvider>(
                                                          context)
                                                      .user!
                                                      .selectedClub
                                                      .id)
                                              ? Colors.green
                                              : Colors.blueGrey,
                                          radius:
                                              24, // Increase the radius as needed
                                          child: Text(
                                            (index + 1).toString(),
                                            style: TextStyle(
                                              fontSize:
                                                  24, // Replace 20 with your desired font size
                                            ),
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              24), // Adjust border radius as needed
                                          side: const BorderSide(
                                            color:
                                                Colors.blueGrey, // Border color
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                club.nameClub,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      24, // Increase the font size as needed
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6.0),
                                            // club.getLastResults(),
                                          ],
                                        ),
                                        subtitle: Text(
                                            'Creation Date: ${DateFormat.yMMMMd('en_US').format(club.createdAt)}'),
                                      ),
                                      if (club.id ==
                                          Provider.of<SessionProvider>(context)
                                              .user!
                                              .selectedClub
                                              .id)
                                        Column(
                                          children: [
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            _quickAccessWidget(
                                                context,
                                                Provider.of<SessionProvider>(
                                                        context)
                                                    .user!
                                                    .selectedClub),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _quickAccessWidget(BuildContext context, Club club) {
    double containerWidth = 80;
    double containerImgRadius = 24;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      /// Players box
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayersPage(
                  // idClub: club.id_club,
                  inputCriteria: {
                    'Clubs': [club.id]
                  }),
            ),
          );
        },
        child: Container(
          width: containerWidth, // Fixed width for each tile
          height: containerWidth, // Fixed height for each tile
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(6), // Adjust border radius as needed
            border: Border.all(
              color: Colors.blueGrey, // Border color
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text('Players [${club.player_count}]'),
              Text('Players'),
              CircleAvatar(
                radius: containerImgRadius,
                child: Icon(
                  icon_players,
                  size: containerImgRadius,
                ),
              ),
            ],
          ),
        ),
      ),

      /// Transfers box
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransferPage(
                idClub: club.id,
              ),
            ),
          );
        },
        child: Container(
          width: containerWidth, // Fixed width for each tile
          height: containerWidth, // Fixed height for each tile
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(6), // Adjust border radius as needed
            border: Border.all(
              color: Colors.blueGrey, // Border color
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Transfers'),
              CircleAvatar(
                radius: containerImgRadius,
                child: Icon(
                  icon_transfers,
                  size: containerImgRadius,
                ),
              ),
            ],
          ),
        ),
      ),

      /// Games box
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GamesPage(
                idClub: club.id,
              ),
            ),
          );
        },
        child: Container(
          width: containerWidth, // Fixed width for each tile
          height: containerWidth, // Fixed height for each tile
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(6), // Adjust border radius as needed
            border: Border.all(
              color: Colors.blueGrey, // Border color
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Games'),
              CircleAvatar(
                radius: containerImgRadius,
                child: Icon(
                  icon_games,
                  size: containerImgRadius,
                ),
              ),
            ],
          ),
        ),
      ),

      /// Ranking box
      InkWell(
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
        child: Container(
          width: containerWidth, // Fixed width for each tile
          height: containerWidth, // Fixed height for each tile
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(6), // Adjust border radius as needed
            border: Border.all(
              color: Colors.blueGrey, // Border color
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('League'),
              CircleAvatar(
                radius: containerImgRadius,
                child: Icon(
                  icon_league,
                  size: containerImgRadius,
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
