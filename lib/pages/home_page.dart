import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/widgets/appBar.dart';
import 'package:opengoalz/widgets/appDrawer.dart';

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
  // Declare a Stream variable to hold the clubs data
  late final Stream<List<Club>> _clubStream;

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;

    _clubStream = supabase
        .from('view_clubs')
        .stream(primaryKey: ['id'])
        .eq('id_user', myUserId) // Filter clubs by user ID
        .order('created_at')
        .map((maps) => maps
            .map((map) => Club.fromMap(map: map, myUserId: myUserId))
            .toList());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        pageName: 'Home',
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Club>>(
        stream: _clubStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final clubs = snapshot.data ?? [];
            return clubs.isEmpty
                ? const Center(child: Text('No clubs found'))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Text('Hello ${clubs[0].username} !',
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 16),
                      Text('Club name: ${clubs[0].club_name}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: clubs.length,
                          itemBuilder: (context, index) {
                            final club = clubs[index];
                            return ListTile(
                              title: Text(club.club_name),
                              // Add onTap handler here to navigate to club details
                            );
                          },
                        ),
                      ),
                    ],
                  );
          }
        },
      ),
    );
  }
}
