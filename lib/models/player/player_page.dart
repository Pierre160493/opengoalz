// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:opengoalz/widgets/max_width_widget.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:opengoalz/classes/club/club.dart';
// import 'package:opengoalz/classes/transfer_bid.dart';
// import 'package:opengoalz/widgets/appDrawer.dart';
// import 'package:opengoalz/classes/player/player_card.dart';
// import 'class/player.dart';
// import '../../constants.dart';

// class PlayerPage extends StatefulWidget {
//   final bool
//       isReturningId; // Should the page return the id of the player clicked ?

//   const PlayerPage(
//       {Key? key, this.isReturningId = false})
//       : super(key: key);

//   static Route<void> route() {
//     return MaterialPageRoute(
//       builder: (context) => PlayerPage(),
//     );
//   }

//   @override
//   State<PlayerPage> createState() => _PlayersPageState();
// }

// class _PlayersPageState extends State<PlayerPage> {
//   late Stream<List<Player>> _playerStream;
//   late Stream<List<Club>> _clubStream;
//   late Stream<List<TransferBid>> _transferBids;

//   @override
//   void initState() {
//     super.initState();

//     // Stream to fetch players
//     if (widget.inputCriteria.containsKey('Clubs')) {
//       _playerStream = supabase
//           .from('players')
//           .stream(primaryKey: ['id'])
//           .inFilter('id_club', widget.inputCriteria['Clubs']!)
//           .order('date_birth', ascending: true)
//           .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
//     } else if (widget.inputCriteria.containsKey('Players')) {
//       _playerStream = supabase
//           .from('players')
//           .stream(primaryKey: ['id'])
//           .inFilter('id', widget.inputCriteria['Players']!)
//           .order('date_birth', ascending: true)
//           .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
//     } else if (widget.inputCriteria.containsKey('Countries')) {
//       throw ArgumentError('Not implemented yet');
//     } else {
//       throw ArgumentError('Invalid input type');
//     }

//     // Stream to fetch clubs from the list of clubs in the players list
//     _clubStream = _playerStream.switchMap((players) {
//       final clubIds = players.map((player) => player.idClub).toSet().toList();
//       return supabase
//           .from('clubs')
//           .stream(primaryKey: ['id'])
//           .inFilter('id', clubIds.cast<Object>())
//           .map((maps) => maps.map((map) => Club.fromMap(map: map)).toList());
//     });
//     // Combine player and club streams
//     _playerStream =
//         _playerStream.switchMap((players) => _clubStream.map((clubs) {
//               for (var player in players) {
//                 final clubData =
//                     clubs.firstWhere((club) => club.id == player.idClub);
//                 player.club = clubData;
//               }
//               return players;
//             }));

//     // Stream to fetch transfer bids for each player
//     _transferBids = _playerStream.switchMap((players) {
//       final playerIds = players.map((player) => player.id).toSet().toList();
//       return supabase
//           .from('transfers_bids')
//           .stream(primaryKey: ['id'])
//           .inFilter('id_player', playerIds.cast<Object>())
//           .order('count_bid', ascending: true)
//           .map((maps) => maps.map((map) => TransferBid.fromMap(map)).toList());
//     });

//     // Combine player and transfer bids streams
//     _playerStream =
//         _playerStream.switchMap((players) => _transferBids.map((transferBids) {
//               for (var player in players) {
//                 player.transferBids.clear();
//                 player.transferBids.addAll(
//                     transferBids.where((bid) => bid.idPlayer == player.id));
//               }
//               return players;
//             }));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<Player>>(
//         stream: _playerStream,
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
//             // final players = snapshot.data ?? [];
//             final List<Player> players = (snapshot.data ?? []);
//             if (players.isEmpty) {
//               return const Center(
//                 child: Text('ERROR: No players found'),
//               );
//             } else {
//               return Scaffold(
//                   // backgroundColor: Colors.grey[700],
//                   appBar: AppBar(
//                     title: players.length == 1
//                         ? Text(
//                             '${players.last.firstName} ${players.last.lastName.toUpperCase()}')
//                         : Text(
//                             '${players.length} Players',
//                           ),
//                     backgroundColor: Colors.green,
//                     elevation: 0,
//                     actions: [
//                       IconButton(
//                         onPressed: () {
//                           // Add your action here
//                         },
//                         icon: Icon(Icons.search),
//                       ),
//                       PopupMenuButton<String>(
//                         // icon: Icons.filter_alt_outlined,
//                         itemBuilder: (BuildContext context) =>
//                             <PopupMenuEntry<String>>[
//                           PopupMenuItem<String>(
//                               // value: 'sort_by_title',
//                               child: Row(
//                             children: [
//                               Icon(
//                                 Icons.sort,
//                                 color: Colors.green,
//                                 size: 36,
//                               ),
//                               Text(' Sort Players By',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   )),
//                             ],
//                           )),
//                           const PopupMenuDivider(),
//                           PopupMenuItem<String>(
//                             value: 'age_asc',
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.cake_outlined,
//                                   color: Colors.green,
//                                 ),
//                                 Text(' Age '),
//                                 Icon(Icons.arrow_outward_outlined),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem<String>(
//                             value: 'age_desc',
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.cake_outlined,
//                                   color: Colors.green,
//                                 ),
//                                 Text(' Age '),
//                                 Icon(Icons.arrow_downward),
//                               ],
//                             ),
//                           ),
//                           const PopupMenuItem<String>(
//                             value: 'last_name',
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.sort_by_alpha_outlined,
//                                   color: Colors.green,
//                                 ),
//                                 Text(' Last Name'),
//                               ],
//                             ),
//                           ),
//                           const PopupMenuItem<String>(
//                             value: 'first_name',
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.sort_by_alpha_outlined,
//                                   color: Colors.green,
//                                 ),
//                                 Text(' First Name'),
//                               ],
//                             ),
//                           ),
//                           // Add other sorting options here
//                         ],
//                         onSelected: (String value) {
//                           // Handle the selected option
//                           if (value == 'age_asc') {
//                             setState(() {
//                               players.sort(
//                                   (a, b) => b.dateBirth.compareTo(a.dateBirth));
//                             });
//                           } else if (value == 'age_desc') {
//                             setState(() {
//                               players.sort(
//                                   (a, b) => a.dateBirth.compareTo(b.dateBirth));
//                             });
//                           } else if (value == 'last_name') {
//                             setState(() {
//                               players.sort(
//                                   (a, b) => a.lastName.compareTo(b.lastName));
//                             });
//                           } else if (value == 'first_name') {
//                             setState(() {
//                               players.sort(
//                                   (a, b) => a.firstName.compareTo(b.firstName));
//                             });
//                           } // Add other options as needed
//                         },
//                       ),
//                     ],
//                   ),
//                   drawer: (widget.isReturningId || players.length == 1)
//                       ? null
//                       : const AppDrawer(),
//                   body: MaxWidthContainer(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: players.length,
//                             itemBuilder: (context, index) {
//                               final Player player = players[index];
//                               return InkWell(
//                                 onTap: () {
//                                   if (widget.isReturningId) {
//                                     Navigator.of(context).pop(player
//                                         .id); // Return the id of the player
//                                   } else if (players.length > 1) {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => PlayersPage(
//                                           inputCriteria: {
//                                             'Players': [player.id]
//                                           },
//                                         ),
//                                       ),
//                                     );
//                                   } else {
//                                     // Handle logic for single player directly
//                                   }
//                                 },
//                                 child: Column(
//                                   children: [
//                                     // Text('${index + 1}'),
//                                     PlayerCard(
//                                         player: player,
//                                         number:
//                                             players.length == 1 ? 0 : index + 1,
//                                         isExpanded:
//                                             players.length == 1 ? true : false),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         )
//                       ],
//                     ),
//                   ));
//             }
//           }
//         });
//   }
// }
