// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:opengoalz/classes/club/club.dart';
// import 'package:opengoalz/classes/league/league.dart';
// import 'package:opengoalz/classes/player/class/player.dart';
// import 'package:opengoalz/constants.dart';
// import 'package:opengoalz/classes/player/players_page.dart';
// import 'package:opengoalz/pages/league_page.dart';
// import 'package:opengoalz/widgets/max_width_widget.dart';
// import 'package:rxdart/rxdart.dart';

// class ClubPage extends StatefulWidget {
//   final int idClub;
//   const ClubPage({Key? key, required this.idClub}) : super(key: key);

//   static Route<void> route(int idClub) {
//     return MaterialPageRoute(
//       builder: (context) => ClubPage(idClub: idClub),
//     );
//   }

//   @override
//   State<ClubPage> createState() => _ClubPageState();
// }

// class _ClubPageState extends State<ClubPage> {
//   late Stream<Club> _clubStream;

//   @override
//   void initState() {
//     super.initState();

//     _clubStream = supabase

//         /// Fetch the club
//         .from('clubs')
//         .stream(primaryKey: ['id'])
//         .eq('id', widget.idClub)
//         .map((maps) => maps
//             .map((map) =>
//                 Club.fromMap(map: map, myUserId: supabase.auth.currentUser!.id))
//             .first)

//         /// Fetch its league
//         .switchMap((Club club) {
//           return supabase
//               .from('leagues')
//               .stream(primaryKey: ['id'])
//               .eq('id', club.idLeague)
//               .map((maps) => maps.map((map) => League.fromMap(map)).first)
//               .map((League league) {
//                 club.league = league;
//                 return club;
//               });
//         })

//         /// Fetch its players
//         .switchMap((Club club) {
//           return supabase
//               .from('players')
//               .stream(primaryKey: ['id'])
//               .eq('id_club', club.id)
//               .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
//               .map((players) {
//                 club.players = players;
//                 return club;
//               });
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<Club>(
//       stream: _clubStream,
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Center(child: Text('Error occurred: ${snapshot.error}'));
//         } else if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         } else {
//           Club club = snapshot.data!;
//           return Scaffold(
//             appBar: AppBar(
//               title: Text('${club.nameClub}'),
//               backgroundColor: Colors.green,
//             ),
//             // drawer: const AppDrawer(),
//             body: MaxWidthContainer(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Card(
//                     elevation: 12, // Adjust the elevation as needed
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(
//                           24), // Adjust border radius as needed
//                     ),
//                     child: Column(
//                       children: [
//                         ListTile(
//                           leading: Icon(
//                             icon_club,
//                             size: 48,
//                           ), // Icon to indicate club
//                           title: Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   club.nameClub,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize:
//                                         24, // Increase the font size as needed
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 6.0),
//                               // club.getLastResults(),
//                               // if (club.id_club ==
//                               //     Provider.of<SessionProvider>(
//                               //             context)
//                               //         .selectedClub
//                               //         .id_club)
//                               //   const Icon(
//                               //     Icons.check_circle,
//                               //     color: Colors.green,
//                               //     size:
//                               //         30, // Increase the icon size as needed
//                               //   )
//                               // else
//                               //   const Icon(
//                               //     Icons.cancel,
//                               //     color: Colors.red,
//                               //     size:
//                               //         30, // Increase the icon size as needed
//                               //   )
//                             ],
//                           ),
//                           subtitle: Row(
//                             children: [
//                               Text(
//                                 'Creation Date: ',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 '${DateFormat.yMMMMd('en_US').format(club.createdAt)}',
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 6),

//                         /// Username of the club owner
//                         ListTile(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                                 24), // Adjust border radius as needed
//                             side: const BorderSide(
//                               color: Colors.blueGrey, // Border color
//                             ),
//                           ),
//                           leading: const Icon(
//                             Icons.account_circle,
//                             size: 30,
//                           ), // Icon to indicate players
//                           title: Text(
//                             club.userName ?? 'Bot Club',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           subtitle: Row(
//                             children: [
//                               Text(
//                                 'Since: ',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                   '${DateFormat.yMMMMd('en_US').format(club.createdAt)}'),
//                             ],
//                           ),
//                         ),

//                         /// Players
//                         const SizedBox(height: 6),
//                         ListTile(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       PlayersPage(inputCriteria: {
//                                         'Clubs': [club.id]
//                                       })),
//                             );
//                           },
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                                 24), // Adjust border radius as needed
//                             side: const BorderSide(
//                               color: Colors.blueGrey, // Border color
//                             ),
//                           ),
//                           leading: const Icon(
//                             Icons.people,
//                             size: 30,
//                           ), // Icon to indicate players
//                           title: Text(
//                             'Number of players: ${club.players.length}',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),

//                         /// League
//                         const SizedBox(height: 6),
//                         ListTile(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => LeaguePage(
//                                   idLeague: club.idLeague,
//                                 ),
//                               ),
//                             );
//                           },
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                                 24), // Adjust border radius as needed
//                             side: const BorderSide(
//                               color: Colors.blueGrey, // Border color
//                             ),
//                           ),
//                           leading: const Icon(
//                             icon_league,
//                             size: 30,
//                           ), // Icon to indicate players
//                           title: club.league == null
//                               ? Text('League Not Found')
//                               : club.league!.getLeagueName(),
//                           subtitle: Row(
//                             children: [
//                               Text(
//                                 'Country: ',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               // Text('${club.name_country}'),
//                               Text('Country'),
//                             ],
//                           ),
//                         ),

//                         /// Finances
//                         const SizedBox(height: 6),
//                         ListTile(
//                           onTap: () {},
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                                 24), // Adjust border radius as needed
//                             side: const BorderSide(
//                               color: Colors.blueGrey, // Border color
//                             ),
//                           ),
//                           leading: const Icon(
//                             icon_finance,
//                             size: 30,
//                           ), // Icon to indicate players
//                           title: Row(
//                             children: [
//                               Text(
//                                 'Finances: ',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               // Text('${club.league_level}.${club.id_league}'),
//                               Text('${club.cashAbsolute}'),
//                             ],
//                           ),
//                           // subtitle: Row(
//                           //   children: [
//                           //     Text(
//                           //       'Country: ',
//                           //       style: const TextStyle(
//                           //         fontWeight: FontWeight.bold,
//                           //       ),
//                           //     ),
//                           //     // Text('${club.name_country}'),
//                           //     Text('Country'),
//                           //   ],
//                           // ),
//                         ),

//                         /// Fans
//                         const SizedBox(height: 6),
//                         ListTile(
//                           onTap: () {},
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                                 24), // Adjust border radius as needed
//                             side: const BorderSide(
//                               color: Colors.blueGrey, // Border color
//                             ),
//                           ),
//                           leading: const Icon(
//                             icon_fans,
//                             size: 30,
//                           ), // Icon to indicate players
//                           title: Row(
//                             children: [
//                               Text(
//                                 'Fan Club Size: ',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               // Text('${club.league_level}.${club.id_league}'),
//                               Text('${club.numberFans}'),
//                             ],
//                           ),
//                           subtitle: Row(
//                             children: [
//                               Text(
//                                 'Mood: ',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               // Text('${club.name_country}'),
//                               Text('Happy'),
//                             ],
//                           ),
//                         ),

//                         /// Stadium
//                         const SizedBox(height: 6),
//                         ListTile(
//                           onTap: () {},
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                                 24), // Adjust border radius as needed
//                             side: const BorderSide(
//                               color: Colors.blueGrey, // Border color
//                             ),
//                           ),
//                           leading: const Icon(
//                             icon_stadium,
//                             size: 30,
//                           ), // Icon to indicate players
//                           title: Row(
//                             children: [
//                               Text(
//                                 'Stadium Name: ',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               // Text('${club.name_stadium}'),
//                               Text('Jardin de los Sueños'),
//                             ],
//                           ),
//                           subtitle: Row(
//                             children: [
//                               Text(
//                                 'Size: ',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               // Text('${club.name_country}'),
//                               Text('12000 [10000 ; 1750 ; 250]'),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }
// }
