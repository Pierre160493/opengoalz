import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/club_view.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/player/players_page.dart';
import 'package:opengoalz/pages/ranking_page.dart';
import 'package:provider/provider.dart';

import '../classes/club.dart';

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
  Stream<List<ClubView>> _clubStream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    _clubStream = _fetchPlayersStream(widget.idClub);
  }

  Stream<List<ClubView>> _fetchPlayersStream(int idClub) {
    return supabase
        .from('view_clubs')
        .stream(primaryKey: ['id'])
        .eq('id_club', idClub)
        .map((maps) => maps
            .map((map) => ClubView.fromMap(
                map: map, myUserId: supabase.auth.currentUser!.id))
            .toList());
  }

  // Method to update the stream and force the StreamBuilder to rebuild
  Stream<List<ClubView>> _updateClubStream() {
    _clubStream = _fetchPlayersStream(widget.idClub);
    setState(() {});
    return _clubStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClubView>>(
      stream: _clubStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final clubs = snapshot.data!;
          if (clubs.length == 0)
            return Text('Error: No club found with id ${widget.idClub}');
          else if (clubs.length > 1)
            return Text('Error: Multiple clubs found with id ${widget.idClub}');
          else
            return Scaffold(
              appBar:
                  // CustomAppBar(pageName: clubs[0].club_name ?? 'No club name'),
                  _buildAppBar(clubs[0]),
              // drawer: const AppDrawer(),
              body: clubs.isEmpty
                  ? const Center(child: Text('No clubs found'))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
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
                                      onTap: () {},
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
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            'Creation Date: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${DateFormat.yMMMMd('en_US').format(club.created_at)}',
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// User
                                    const SizedBox(height: 6),
                                    ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            24), // Adjust border radius as needed
                                        side: const BorderSide(
                                          color:
                                              Colors.blueGrey, // Border color
                                        ),
                                      ),
                                      leading: const Icon(
                                        Icons.account_circle,
                                        size: 30,
                                      ), // Icon to indicate players
                                      title: Row(
                                        children: [
                                          Text(
                                            'User: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Text(
                                          //   '${club.username ?? 'No username'}',
                                          // ),
                                        ],
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            'Since: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                              '${DateFormat.yMMMMd('en_US').format(club.created_at)}'),
                                        ],
                                      ),
                                    ),

                                    /// Players
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
                                          color:
                                              Colors.blueGrey, // Border color
                                        ),
                                      ),
                                      leading: const Icon(
                                        Icons.people,
                                        size: 30,
                                      ), // Icon to indicate players
                                      title: Text(
                                        // 'Number of players: ${club.player_count}',
                                        'Number of players:',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    /// League
                                    const SizedBox(height: 6),
                                    ListTile(
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            24), // Adjust border radius as needed
                                        side: const BorderSide(
                                          color:
                                              Colors.blueGrey, // Border color
                                        ),
                                      ),
                                      leading: const Icon(
                                        icon_rankings,
                                        size: 30,
                                      ), // Icon to indicate players
                                      title: Row(
                                        children: [
                                          Text(
                                            'League: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Text('${club.league_level}.${club.id_league}'),
                                          Text('1.${club.id_league}'),
                                        ],
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            'Country: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Text('${club.name_country}'),
                                          Text('Country'),
                                        ],
                                      ),
                                    ),

                                    /// Finances
                                    const SizedBox(height: 6),
                                    ListTile(
                                      onTap: () {},
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            24), // Adjust border radius as needed
                                        side: const BorderSide(
                                          color:
                                              Colors.blueGrey, // Border color
                                        ),
                                      ),
                                      leading: const Icon(
                                        icon_finance,
                                        size: 30,
                                      ), // Icon to indicate players
                                      title: Row(
                                        children: [
                                          Text(
                                            'Finances: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Text('${club.league_level}.${club.id_league}'),
                                          Text('${club.cash_absolute}'),
                                        ],
                                      ),
                                      // subtitle: Row(
                                      //   children: [
                                      //     Text(
                                      //       'Country: ',
                                      //       style: const TextStyle(
                                      //         fontWeight: FontWeight.bold,
                                      //       ),
                                      //     ),
                                      //     // Text('${club.name_country}'),
                                      //     Text('Country'),
                                      //   ],
                                      // ),
                                    ),

                                    /// Fans
                                    const SizedBox(height: 6),
                                    ListTile(
                                      onTap: () {},
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            24), // Adjust border radius as needed
                                        side: const BorderSide(
                                          color:
                                              Colors.blueGrey, // Border color
                                        ),
                                      ),
                                      leading: const Icon(
                                        icon_fans,
                                        size: 30,
                                      ), // Icon to indicate players
                                      title: Row(
                                        children: [
                                          Text(
                                            'Fan Club Size: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Text('${club.league_level}.${club.id_league}'),
                                          Text('${club.number_fans}'),
                                        ],
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            'Mood: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Text('${club.name_country}'),
                                          Text('Happy'),
                                        ],
                                      ),
                                    ),

                                    /// Stadium
                                    const SizedBox(height: 6),
                                    ListTile(
                                      onTap: () {},
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            24), // Adjust border radius as needed
                                        side: const BorderSide(
                                          color:
                                              Colors.blueGrey, // Border color
                                        ),
                                      ),
                                      leading: const Icon(
                                        icon_stadium,
                                        size: 30,
                                      ), // Icon to indicate players
                                      title: Row(
                                        children: [
                                          Text(
                                            'Stadium Name: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Text('${club.name_stadium}'),
                                          Text('Jardin de los Sueños'),
                                        ],
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            'Size: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Text('${club.name_country}'),
                                          Text('12000 [10000 ; 1750 ; 250]'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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

  PreferredSizeWidget _buildAppBar(ClubView club) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        title: Row(
          children: [
            Text(
              '${club.club_name} ',
            ),
          ],
        ),
      ),
    );
  }
}
