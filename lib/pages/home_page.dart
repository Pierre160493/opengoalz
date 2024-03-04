import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
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
  late final Stream<List<Club>> _clubStream;

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;

    _clubStream = supabase
        .from('view_clubs')
        .stream(primaryKey: ['id'])
        .eq('id_user', myUserId)
        .order('created_at')
        .map((maps) => maps
            .map((map) => Club.fromMap(map: map, myUserId: myUserId))
            .toList());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Club>>(
      stream: Provider.of<SessionProvider>(context).clubStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final clubs = snapshot.data!;
          return Scaffold(
            appBar: CustomAppBar(
                pageName:
                    clubs[Provider.of<SessionProvider>(context).nClubInList]
                            .club_name ??
                        'No club name'),
            // CustomAppBar(clubStream: _clubStream),
            // drawer: AppDrawer(clubStream: _clubStream),
            drawer: const AppDrawer(),
            body: clubs.isEmpty
                ? const Center(child: Text('No clubs found'))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Hello ${clubs[Provider.of<SessionProvider>(context).nClubInList].username} !',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          text:
                              'Selected club [${Provider.of<SessionProvider>(context).nClubInList}]: ',
                          style: const TextStyle(fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                              text: clubs[Provider.of<SessionProvider>(context)
                                      .nClubInList]
                                  .club_name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'List of clubs:',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: clubs.length,
                          itemBuilder: (context, index) {
                            final club = clubs[index];
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  // Define the action you want to perform when the ListTile is tapped
                                  // For example, you can navigate to a new screen or show a dialog
                                  print('Tapped on club: ${club.club_name}');
                                  Provider.of<SessionProvider>(context,
                                          listen: false)
                                      .setnClubInList(index);
                                },
                                leading: CircleAvatar(
                                  child: Text((index + 1)
                                      .toString()), // Display index with +1 to start from 1 instead of 0
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        club.club_name ?? 'ERROR: No club name',
                                      ),
                                    ),
                                    if (index ==
                                        Provider.of<SessionProvider>(context)
                                            .nClubInList)
                                      const Icon(Icons.check_circle,
                                          color: Colors
                                              .green), // Display green tick icon if index matches nClubInList
                                  ],
                                ),
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
