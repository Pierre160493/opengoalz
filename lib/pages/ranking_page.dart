// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:opengoalz/widgets/appBar.dart';
// import 'package:opengoalz/widgets/appDrawer.dart';
// import 'package:opengoalz/widgets/player_card_single.dart';

// import '../classes/player.dart';
// import '../constants.dart';

// class RankingPage extends StatefulWidget {

//   const RankingPage({Key? key}) : super(key: key);

//   static Route<void> route(int idPlayer) {
//     return MaterialPageRoute<void>(
//       builder: (context) => const RankingPage(),
//     );
//   }

//   @override
//   State<RankingPage> createState() => _HomePageState();
// }

// class _HomePageState extends State<RankingPage> {
//   late final Stream<List<Player>> _rankingStream;

//   @override
//   void initState() {
//     final myUserId = supabase.auth.currentUser!.id;

//     _rankingStream = _fetchPlayersStream(myUserId);

//     super.initState();
//   }

//   Stream<List<Ranking>> _fetchPlayersStream(String myUserId) async* {
//   // Fetch the id_league associated with myUserId
//   final response = await supabase
//       .from('users')
//       .select('id_league')
//       .eq('id', myUserId)
//       .execute();

//   // Extract the id_league from the response
//   final idLeague = response.data?[0]['id_league'] as String?;

//   // Check if id_league is available
//   if (idLeague != null) {
//     // Use id_league to make the query
//     var query = supabase
//         .from('view_ranking')
//         .stream(primaryKey: ['id'])
//         .eq('id_league', idLeague)
//         .order('created_at');

//     // Yield the result of the query
//     yield* query.map((maps) => maps
//         .map((map) => Ranking.fromMap(map: map, myUserId: myUserId))
//         .toList());
//   } else {
//     // Handle the case where id_league is not available
//     // For example, show an error message or return an empty list
//     yield [];
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(
//         pageName: 'Rankings Page',
//       ),
//       drawer: const AppDrawer(),
//       body: StreamBuilder<List<Ranking>>(
//         stream: _rankingStream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('ERROR: ${snapshot.error}'),
//             );
//           } else {
//             final players = snapshot.data ?? [];
//             if (players.isEmpty) {
//               return const Center(
//                 child: Text('ERROR: No players found'),
//               );
//             }
//             if (players.length != 1) {
//               return Center(
//                 child: Text('ERROR: ${players.length} players found'),
//               );
//             } else {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: players.length,
//                       itemBuilder: (context, index) {
//                         final player = players[index];
//                         return PlayerCardSingle(player: player);
//                       },
//                     ),
//                   )
//                 ],
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }
