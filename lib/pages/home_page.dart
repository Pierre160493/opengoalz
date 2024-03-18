import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/pages/players_page.dart';
import 'package:opengoalz/widgets/appBar.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:provider/provider.dart';

import '../classes/club.dart';

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
  late Stream<List<Club>> _clubStream;
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
    return StreamBuilder<List<Club>>(
      stream: _clubStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final clubs = snapshot.data!;
          return Scaffold(
            appBar: CustomAppBar(
                pageName: Provider.of<SessionProvider>(context)
                        .selectedClub
                        .club_name ??
                    'No club name'),
            drawer: const AppDrawer(),
            body: clubs.isEmpty
                ? const Center(child: Text('No clubs found'))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
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
                            return Card(
                              elevation: 12, // Adjust the elevation as needed
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    24), // Adjust border radius as needed
                              ),
                              child: Column(
                                children: [
                                  // const SizedBox(height: 12),
                                  ListTile(
                                    onTap: () {
                                      Provider.of<SessionProvider>(context,
                                              listen: false)
                                          .setselectedClub(club);
                                    },
                                    leading: CircleAvatar(
                                      radius:
                                          24, // Increase the radius as needed
                                      child: Text((index + 1)
                                          .toString()), // Display index with +1 to start from 1 instead of 0
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          24), // Adjust border radius as needed
                                      side: const BorderSide(
                                        color: Colors.blueGrey, // Border color
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            club.club_name ??
                                                'ERROR: No club name',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  24, // Increase the font size as needed
                                            ),
                                          ),
                                        ),
                                        if (club.id_club ==
                                            Provider.of<SessionProvider>(
                                                    context)
                                                .selectedClub
                                                .id_club)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size:
                                                30, // Increase the icon size as needed
                                          )
                                        else
                                          const Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                            size:
                                                30, // Increase the icon size as needed
                                          )
                                      ],
                                    ),
                                    subtitle: Text(
                                        'Creation Date: ${DateFormat.yMMMMd('en_US').format(club.created_at)}'),
                                  ),
                                  const SizedBox(height: 6),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlayersPage(
                                            idClub: club.id_club,
                                          ),
                                        ),
                                      );
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          24), // Adjust border radius as needed
                                      side: const BorderSide(
                                        color: Colors.blueGrey, // Border color
                                      ),
                                    ),
                                    leading: const Icon(Icons
                                        .people), // Icon to indicate players
                                    title: Text(
                                      'Number of players: ${club.player_count}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // child: ListTile(
                              //   onTap: () {
                              //     Provider.of<SessionProvider>(context,
                              //             listen: false)
                              //         .setselectedClub(club);
                              //   },
                              //   leading: CircleAvatar(
                              //     child: Text((index + 1)
                              //         .toString()), // Display index with +1 to start from 1 instead of 0
                              //   ),
                              //   title: Row(
                              //     children: [
                              //       Expanded(
                              //         child: Text(
                              //           club.club_name ?? 'ERROR: No club name',
                              //           style: const TextStyle(
                              //               fontWeight: FontWeight.bold),
                              //         ),
                              //       ),
                              //       if (club.id_club ==
                              //           Provider.of<SessionProvider>(context)
                              //               .selectedClub
                              //               .id_club)
                              //         const Icon(Icons.check_circle,
                              //             color: Colors
                              //                 .green) // Display green tick icon if index matches nClubInList
                              //       else
                              //         const Icon(Icons.cancel,
                              //             color: Colors
                              //                 .red), // Display red cross icon if index does not match nClubInList
                              //     ],
                              //   ),
                              //   subtitle: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       const SizedBox(height: 8),
                              //       Text(
                              //         'Creation Date: ${DateFormat.yMMMMd('en_US').format(club.created_at)}',
                              //       ),
                              //       const SizedBox(height: 4),
                              //       Text(
                              //         'Cash: ${club.finances_cash}',
                              //       ),
                              //       const SizedBox(height: 4),
                              //       ListTile(
                              //         onTap: () {
                              //           Navigator.push(
                              //             context,
                              //             MaterialPageRoute(
                              //               builder: (context) => PlayersPage(
                              //                 idClub: club.id_club,
                              //               ),
                              //             ),
                              //           );
                              //         },
                              //         // contentPadding: const EdgeInsets.all(
                              //         //     3), // Adjust padding as needed
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(
                              //               24), // Adjust border radius as needed
                              //           side: const BorderSide(
                              //             color:
                              //                 Colors.blueGrey, // Border color
                              //           ),
                              //         ),
                              //         leading: const Icon(Icons
                              //             .people), // Icon to indicate players
                              //         title: Text(
                              //           'Number of players: ${club.player_count}',
                              //           style: const TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //           ),
                              //         ),
                              //       ),
                              //       const SizedBox(height: 3),
                              //       ListTile(
                              //         onTap: () {
                              //           Navigator.push(
                              //             context,
                              //             MaterialPageRoute(
                              //               builder: (context) => PlayersPage(
                              //                 idClub: club.id_club,
                              //               ),
                              //             ),
                              //           );
                              //         },
                              //         // contentPadding: const EdgeInsets.all(
                              //         //     3), // Adjust padding as needed
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(
                              //               24), // Adjust border radius as needed
                              //           side: const BorderSide(
                              //             color:
                              //                 Colors.blueGrey, // Border color
                              //           ),
                              //         ),
                              //         leading: const Icon(Icons
                              //             .people), // Icon to indicate players
                              //         title: Text(
                              //           'Number of players: ${club.player_count}',
                              //           style: const TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //           ),
                              //         ),
                              //       ),
                              //       Text(
                              //         'Fan club size: ${club.fans_total_number}',
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            );
                          },
                        ),
                      ),
                    ],
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
}
