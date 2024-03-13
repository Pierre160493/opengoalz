import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/pages/players_page.dart';
import 'package:opengoalz/widgets/appBar.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';

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
  Stream<List<Club>> _clubStream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    _clubStream = _fetchPlayersStream(widget.idClub);
  }

  Stream<List<Club>> _fetchPlayersStream(int idClub) {
    return supabase
        .from('view_clubs')
        .stream(primaryKey: ['id'])
        .eq('id_club', idClub)
        .map((maps) => maps
            .map((map) =>
                Club.fromMap(map: map, myUserId: supabase.auth.currentUser!.id))
            .toList());
  }

  // Method to update the stream and force the StreamBuilder to rebuild
  Stream<List<Club>> _updateClubStream() {
    _clubStream = _fetchPlayersStream(widget.idClub);
    setState(() {});
    return _clubStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Club>>(
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
              // appBar:
              //     CustomAppBar(pageName: clubs[0].club_name ?? 'No club name'),
              drawer: const AppDrawer(),
              body: clubs.isEmpty
                  ? const Center(child: Text('No clubs found'))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                      onTap: () {},
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
                                          color:
                                              Colors.blueGrey, // Border color
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
                                          color:
                                              Colors.blueGrey, // Border color
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
