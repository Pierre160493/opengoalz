import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/club_view.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/pages/games_page.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/pages/ranking_page.dart';
import 'package:opengoalz/pages/transfer_page.dart';
import 'package:opengoalz/player/players_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const HomePage(),
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<List<ClubView>> _clubStream;
  @override
  void initState() {
    super.initState();
    _clubStream =
        Provider.of<SessionProvider>(context, listen: false).clubStream;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);
    sessionProvider.updateClubStream(supabase.auth.currentUser!.id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClubView>>(
      stream: _clubStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final clubs = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Column(
                children: [
                  Text('Home Page'),
                  Text(
                    Provider.of<SessionProvider>(context)
                            .selectedClub
                            .name_club ??
                        'Unknown Club',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
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
              child: clubs.isEmpty
                  ? const Center(child: Text('No clubs found'))
                  : Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Hello ${Provider.of<SessionProvider>(context).selectedClub.username ?? 'Unknown Manager'} !',
                          style: const TextStyle(fontSize: 24),
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
                            itemCount: clubs.length,
                            itemBuilder: (context, index) {
                              final club = clubs[index];
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
                                            Provider.of<SessionProvider>(
                                                    context,
                                                    listen: false)
                                                .setselectedClub(club);
                                          },
                                          leading: CircleAvatar(
                                            backgroundColor: club.id_club ==
                                                    Provider.of<SessionProvider>(
                                                            context)
                                                        .selectedClub
                                                        .id_club
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
                                              color: Colors
                                                  .blueGrey, // Border color
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  club.name_club ??
                                                      'ERROR: No club name',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        24, // Increase the font size as needed
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6.0),
                                              club.getLastResults(),
                                            ],
                                          ),
                                          subtitle: Text(
                                              'Creation Date: ${DateFormat.yMMMMd('en_US').format(club.created_at)}'),
                                        ),
                                        if (club.id_club ==
                                            Provider.of<SessionProvider>(
                                                    context)
                                                .selectedClub
                                                .id_club)
                                          Column(
                                            children: [
                                              const SizedBox(
                                                height: 6,
                                              ),
                                              _quickAccessWidget(
                                                  context,
                                                  Provider.of<SessionProvider>(
                                                          context)
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

                        // Expanded(
                        //   child: ListView.builder(
                        //     itemCount: clubs.length,
                        //     itemBuilder: (context, index) {
                        //       final club = clubs[index];
                        //       return Card(
                        //         elevation: 12, // Adjust the elevation as needed
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(
                        //               24), // Adjust border radius as needed
                        //           side: BorderSide(
                        //             color: Colors
                        //                 .blueGrey, // Adjust the color as needed
                        //             width: 2, // Adjust the width as needed
                        //           ),
                        //         ),
                        //         child: Container(
                        //           color: Colors.green,
                        //           child: Column(
                        //             children: [
                        //               // const SizedBox(height: 12),
                        //               ListTile(
                        //                 onTap: () {
                        //                   Provider.of<SessionProvider>(context,
                        //                           listen: false)
                        //                       .setselectedClub(club);
                        //                 },
                        //                 leading: CircleAvatar(
                        //                   radius:
                        //                       24, // Increase the radius as needed
                        //                   child: Text((index + 1)
                        //                       .toString()), // Display index with +1 to start from 1 instead of 0
                        //                 ),
                        //                 shape: RoundedRectangleBorder(
                        //                   borderRadius: BorderRadius.circular(
                        //                       24), // Adjust border radius as needed
                        //                   side: const BorderSide(
                        //                     color:
                        //                         Colors.blueGrey, // Border color
                        //                   ),
                        //                 ),
                        //                 title: Row(
                        //                   children: [
                        //                     if (club.id_club ==
                        //                         Provider.of<SessionProvider>(
                        //                                 context)
                        //                             .selectedClub
                        //                             .id_club)
                        //                       const Icon(
                        //                         Icons.check_circle,
                        //                         color: Colors.green,
                        //                         size:
                        //                             30, // Increase the icon size as needed
                        //                       )
                        //                     else
                        //                       const Icon(
                        //                         Icons.cancel,
                        //                         color: Colors.red,
                        //                         size:
                        //                             30, // Increase the icon size as needed
                        //                       ),
                        //                     const SizedBox(width: 6.0),
                        //                     Expanded(
                        //                       child: Text(
                        //                         club.name_club ??
                        //                             'ERROR: No club name',
                        //                         style: const TextStyle(
                        //                           fontWeight: FontWeight.bold,
                        //                           fontSize:
                        //                               24, // Increase the font size as needed
                        //                         ),
                        //                       ),
                        //                     ),
                        //                     const SizedBox(width: 6.0),
                        //                     club.getLastResults(),
                        //                   ],
                        //                 ),
                        //                 subtitle: Text(
                        //                     'Creation Date: ${DateFormat.yMMMMd('en_US').format(club.created_at)}'),
                        //               ),
                        //               const SizedBox(height: 3),

                        //               SizedBox(
                        //                 height: 6,
                        //               )
                        //             ],
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error occurred: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _quickAccessWidget(BuildContext context, ClubView club) {
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
                    'Clubs': [club.id_club]
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
              Text('Players [${club.player_count}]'),
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
                idClub: club.id_club,
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
                idClub: club.id_club,
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
              builder: (context) => RankingPage(
                idLeague: club.id_league,
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
              Text('Rankings'),
              CircleAvatar(
                radius: containerImgRadius,
                child: Icon(
                  icon_rankings,
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
