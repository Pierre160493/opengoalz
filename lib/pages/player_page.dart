import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/widgets/appBar.dart';
import 'package:opengoalz/widgets/appDrawer.dart';

import '../classes/club.dart';
import '../constants.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const PlayerPage(),
    );
  }

  @override
  State<PlayerPage> createState() => _HomePageState();
}

class _HomePageState extends State<PlayerPage> {
  // Declare a Stream variable to hold the clubs data
  late final Stream<List<Club>> _clubStream;

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;

    _clubStream = supabase
        .from('view_players')
        .stream(primaryKey: ['id'])
        .eq('id_club', myUserId) // Filter clubs by user ID
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
        pageName: 'Players',
      ),
      drawer:
          const AppDrawer(), // Add the Personalized AppDrawer widget to the Scaffold
      body: Column(
        children: [
          // const Row(children: [Text('Hello $_username')]),
          StreamBuilder<List<Club>>(
            stream: _clubStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // or any loading indicator
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final clubs = snapshot.data ?? [];
                if (clubs.isEmpty) {
                  return const Text('No clubs found');
                } else if (clubs.length > 1) {
                  return Text(
                      '${clubs.length} clubs found: Only one possible yet');
                } else {
                  // Display data in Row based on the number of records
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text('Hello ${clubs[0].username} !'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Number of Clubs: ${clubs.length}'),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align text to the start (left)
                        children: clubs.map((club) {
                          return Text(club.club_name);
                        }).toList(),
                      ),
                    ],
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
