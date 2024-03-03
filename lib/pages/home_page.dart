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
      stream: _clubStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final clubs = snapshot.data!;
          return Scaffold(
            appBar:
                CustomAppBar(pageName: clubs[0].club_name ?? 'No club name'),
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
                        'Hello ${clubs[0].username} !',
                        style: const TextStyle(fontSize: 24),
                      ),
                      Text(
                        Provider.of<SessionProvider>(context).isLoggedIn
                            ? 'You are logged in'
                            : 'You are not logged in',
                        style: const TextStyle(fontSize: 24),
                      ),
                      StreamBuilder<List<Club>>(
                        stream:
                            Provider.of<SessionProvider>(context).clubStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final clubs = snapshot.data ?? [];
                            if (clubs.isEmpty) {
                              return Text('No clubs found');
                            } else {
                              final clubName = clubs[0]
                                  .username; // Assuming club name field is named clubName
                              return Text(
                                clubName ??
                                    'No Club Name', // Use 'No Club Name' if clubName is null
                                style: TextStyle(fontSize: 24),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Club name: ${clubs[0].club_name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: clubs.length,
                          itemBuilder: (context, index) {
                            final club = clubs[index];
                            return ListTile(
                              title:
                                  Text(club.club_name ?? 'ERROR: No club name'),
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
