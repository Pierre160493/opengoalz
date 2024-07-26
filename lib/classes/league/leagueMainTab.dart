// part of 'league.dart';

// extension LeagueMainTab on League {
//   Widget leagueMainTab(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(height: 6),

//         /// Season row
//         // Row(
//         //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         //   children: [
//         //     Row(
//         //       children: [
//         //         Icon(
//         //           Icons.calendar_month,
//         //           color: Colors.blueGrey,
//         //           size: 36,
//         //         ),
//         //         SizedBox(width: 8),
//         //         Text(
//         //           'Season ${seasonNumber.toString()}',
//         //           style: TextStyle(
//         //             fontSize: 16,
//         //             fontWeight: FontWeight.bold,
//         //           ),
//         //         ),
//         //         // if (idPreviousSeason != null)
//         //         //   Row(
//         //         //     children: [
//         //         //       // SizedBox(width: 64),
//         //         //       InkWell(
//         //         //         onTap: () {
//         //         //           Navigator.push(
//         //         //             context,
//         //         //             LeaguePage.route(idPreviousSeason!),
//         //         //           );
//         //         //         },
//         //         //         child: Row(
//         //         //           children: [
//         //         //             Icon(Icons.keyboard_double_arrow_left),
//         //         //             Text('Previous Season'),
//         //         //           ],
//         //         //         ),
//         //         //       ),
//         //         //     ],
//         //         //   )
//         //       ],
//         //     ),
//         //     Row(),
//         //   ],
//         // ),

//         /// Other leagues selection widget
//         otherLeaguesSelectionWidget(context),

//         /// Rankings
//         Container(
//           margin: EdgeInsets.symmetric(vertical: 16),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Divider(
//                   color: Colors.grey,
//                   height: 1,
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8),
//                 child: Text(
//                   'Rankings',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 20,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Divider(
//                   color: Colors.grey,
//                   height: 1,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         /// Rankings
//         Expanded(
//           child: ListView.builder(
//             itemCount: clubs.length,
//             itemBuilder: (context, index) {
//               final club = clubs[index];
//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: index == 0
//                       ? Colors.yellow
//                       : index == 1
//                           ? Colors.grey
//                           : index == 2
//                               ? Colors.amber
//                               : Colors.blue, // Set the background color
//                   child: Text(
//                     '${index + 1}',
//                     style: TextStyle(
//                         color: Colors.black, // Set the text color
//                         fontSize: 24),
//                   ),
//                 ),
//                 title: Text(club.nameClub),
//                 subtitle: Row(
//                   children: [
//                     Text('Results: '),
//                     Text(
//                       club.victories.toString(),
//                       style: TextStyle(
//                         color: Colors.green, // Set the text color to green
//                         fontWeight: FontWeight.bold, // Make the text bold
//                       ),
//                     ),
//                     Text(' / '),
//                     Text(
//                       club.draws.toString(),
//                       style: TextStyle(
//                         color: Colors.grey, // Set the text color to green
//                         fontWeight: FontWeight.bold, // Make the text bold
//                       ),
//                     ),
//                     Text(' / '),
//                     Text(
//                       club.defeats.toString(),
//                       style: TextStyle(
//                         color: Colors.red, // Set the text color to green
//                         fontWeight: FontWeight.bold, // Make the text bold
//                       ),
//                     ),
//                     SizedBox(width: 36),
//                     Text('Goal Diff: '),
//                     Text(
//                       (club.goalsScored - club.goalsTaken).toString(),
//                       style: TextStyle(
//                         color: Colors.grey, // Set the text color to green
//                         fontWeight: FontWeight.bold, // Make the text bold
//                       ),
//                     ),
//                     Text(' ( '),
//                     Text(
//                       club.goalsScored.toString(),
//                       style: TextStyle(
//                         color: Colors.green, // Set the text color to green
//                       ),
//                     ),
//                     Text(' / '),
//                     Text(
//                       club.goalsTaken.toString(),
//                       style: TextStyle(
//                         color: Colors.red, // Set the text color to green
//                       ),
//                     ),
//                     Text(' )'),
//                   ],
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     ClubPage.route(club.id),
//                   );
//                 },
//                 trailing: CircleAvatar(
//                   backgroundColor: Colors.grey,
//                   child: Text(
//                     '${club.points.toString()}',
//                     style: TextStyle(
//                         color: Colors.black, // Set the text color
//                         fontSize: 24),
//                   ),
//                 ), // Display the index starting from 1
//               );
//             },
//           ),
//         )

//         /// Rankings tables
//         // Card(
//         //   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         //   child: DataTable(
//         //     columns: const [
//         //       DataColumn(label: Text('Pos')),
//         //       DataColumn(label: Text('Name')),
//         //       DataColumn(label: Text('Points')),
//         //       DataColumn(label: Text('Goal Diff')),
//         //     ],
//         //     rows: rankings.take(6).map((ranking) {
//         //       final index = rankings.indexOf(ranking) + 1;
//         //       var color = index.isOdd ? Colors.blueGrey : null;
//         //       if (ranking.idClub ==
//         //           Provider.of<SessionProvider>(context).selectedClub.id_club)
//         //         color = Colors.green;
//         //       return DataRow(
//         //         color: WidgetStateProperty.all(color),
//         //         onSelectChanged: (_) {
//         //           Navigator.push(
//         //             context,
//         //             ClubPage.route(ranking.idClub),
//         //           );
//         //         },
//         //         cells: [
//         //           DataCell(Text(index.toString())),
//         //           DataCell(
//         //             Container(
//         //               constraints: BoxConstraints(
//         //                 maxWidth: 120, // Set the maximum width here
//         //               ),
//         //               child: Flexible(
//         //                 child: Text(ranking.nameClub,
//         //                     overflow: TextOverflow.ellipsis,
//         //                     style: TextStyle(
//         //                         // fontWeight: FontWeight.bold,
//         //                         fontSize: 12)),
//         //               ),
//         //             ),
//         //           ),

//         //           DataCell(Row(
//         //             children: [
//         //               Text(
//         //                 ranking.nPoints.toString(),
//         //                 style: TextStyle(
//         //                     fontWeight: FontWeight.bold, fontSize: 18),
//         //               ),
//         //               Text(' '),
//         //               Container(
//         //                 padding: EdgeInsets.all(4),
//         //                 color: Colors.black, // Set the background color here
//         //                 child: Row(
//         //                   children: [
//         //                     Text(
//         //                       ranking.nVictories.toString(),
//         //                       style: TextStyle(
//         //                         color: Colors.green,
//         //                       ),
//         //                     ),
//         //                     Text(' / '),
//         //                     Text(
//         //                       ranking.nDraws.toString(),
//         //                       style: TextStyle(
//         //                         color: Colors.white,
//         //                       ),
//         //                     ),
//         //                     Text(' / '),
//         //                     Text(
//         //                       ranking.nDefeats.toString(),
//         //                       style: TextStyle(
//         //                         color: Colors.red,
//         //                       ),
//         //                     ),
//         //                   ],
//         //                 ),
//         //               ),
//         //             ],
//         //           )),
//         //           // DataCell(Text(ranking.totalGoalAverage.toString())),
//         //           DataCell(Row(
//         //             children: [
//         //               Text(
//         //                 ranking.totalGoalAverage.toString(),
//         //                 style: TextStyle(
//         //                     fontWeight: FontWeight.bold, fontSize: 18),
//         //               ),
//         //               Text(' '),
//         //               Container(
//         //                 padding: EdgeInsets.all(4),
//         //                 color: Colors.black, // Set the background color here
//         //                 child: Row(
//         //                   children: [
//         //                     Text(
//         //                       ranking.goalsScored.toString(),
//         //                       style: TextStyle(
//         //                         color: Colors.green,
//         //                       ),
//         //                     ),
//         //                     Text(' / '),
//         //                     Text(
//         //                       ranking.goalsTaken.toString(),
//         //                       style: TextStyle(
//         //                         color: Colors.red,
//         //                       ),
//         //                     ),
//         //                   ],
//         //                 ),
//         //               ),
//         //             ],
//         //           )),
//         //         ],
//         //       );
//         //     }).toList(),
//         //   ),
//         // )
//       ],
//     );
//   }

//   Widget otherLeaguesSelectionWidget(BuildContext context) {
//     return Column(
//       /// Upper League
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             InkWell(
//               onTap: () {
//                 if (idUpperLeague != null) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => LeaguePage(
//                         idLeague: idUpperLeague!,
//                       ),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content:
//                           Text('No upper league for first division leagues'),
//                     ),
//                   );
//                 }
//               },
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.arrow_circle_up, // Changed the icon
//                     color: idUpperLeague == null
//                         ? Colors.blueGrey
//                         : Colors.green, // Changed the icon color
//                     size: 32, // Increased the icon size
//                   ),
//                   const SizedBox(width: 6),
//                   Text('Upper League'),
//                   const SizedBox(width: 6),
//                   Icon(
//                     Icons.arrow_circle_up, // Changed the icon
//                     color: idUpperLeague == null
//                         ? Colors.blueGrey
//                         : Colors.green, // Changed the icon color
//                     size: 32, // Increased the icon size
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),

//         /// Opposite and same level league button
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             /// Same level league button (left)
//             Container(
//               width: 160,
//               child: Row(
//                 children: [
//                   InkWell(
//                     onTap: () async {
//                       if (level == 1) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                                 'No same level league for first division leagues'),
//                           ),
//                         );
//                       } else {
//                         int leagueNumber = number == 1
//                             ? (pow(2, level - 1)).toInt()
//                             : number - 1;
//                         try {
//                           print('Current league level:' + level.toString());
//                           print('Current league number:' + level.toString());
//                           print(level);
//                           print(leagueNumber);
//                           final response = await supabase
//                               .from('leagues')
//                               .select('id')
//                               .eq('multiverse_speed', multiverseSpeed)
//                               .eq('season_number', seasonNumber)
//                               .eq('continent', continent)
//                               .eq('level', level)
//                               .eq('number', leagueNumber)
//                               .limit(1)
//                               .single();

//                           if (response['error'] != null) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                     'Error fetching league: ${response['error']['message']}'),
//                               ),
//                             );
//                           } else if (response['id'] != null) {
//                             print(response['id']);
//                             final idLowerLeague = response['id'];
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => LeaguePage(
//                                   idLeague: idLowerLeague,
//                                 ),
//                               ),
//                             );
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('No lower league found'),
//                               ),
//                             );
//                           }
//                         } on PostgrestException catch (error) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                   'Error fetching league: ${error.message}'),
//                             ),
//                           );
//                         }
//                       }
//                     },
//                     child: Row(
//                       children: [
//                         Text(
//                             'Left (${number - 1 == 0 ? pow(2, level - 1) : number - 1}/${pow(2, level - 1)})'),
//                         const SizedBox(width: 6),
//                         Icon(
//                           Icons.arrow_circle_left, // Changed the icon
//                           color: level == 1
//                               ? Colors.blueGrey
//                               : Colors.green, // Changed the icon color
//                           size: 32, // Increased the icon size
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// Opposite league button
//             InkWell(
//               onTap: () {
//                 if (level > 1) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => LeaguePage(
//                         idLeague: -id,
//                       ),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content:
//                           Text('No opposite league for first division leagues'),
//                     ),
//                   );
//                 }
//               },
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.compare_arrows, // Changed the icon
//                     color: level == 1
//                         ? Colors.blueGrey
//                         : Colors.green, // Changed the icon color
//                     size: 32, // Increased the icon size
//                   ),
//                   const SizedBox(width: 6),
//                   Text('Opposite League'),
//                   const SizedBox(width: 6),
//                   Icon(
//                     Icons.compare_arrows, // Changed the icon
//                     color: level == 1
//                         ? Colors.blueGrey
//                         : Colors.green, // Changed the icon color
//                     size: 32, // Increased the icon size
//                   ),
//                 ],
//               ),
//             ),

//             /// Same level league button (right)
//             Container(
//               width: 160,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   InkWell(
//                     onTap: () async {
//                       if (level == 1) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                                 'No same level league for first division leagues'),
//                           ),
//                         );
//                       } else {
//                         int leagueNumber =
//                             number == pow(2, level - 1) ? 1 : number + 1;
//                         try {
//                           final response = await supabase
//                               .from('leagues')
//                               .select('id')
//                               .eq('multiverse_speed', multiverseSpeed)
//                               .eq('season_number', seasonNumber)
//                               .eq('continent', continent)
//                               .eq('level', level)
//                               .eq('number', leagueNumber)
//                               .limit(1)
//                               .single();

//                           if (response['error'] != null) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                     'Error fetching league: ${response['error']['message']}'),
//                               ),
//                             );
//                           } else if (response['id'] != null) {
//                             print(response['id']);
//                             final idLowerLeague = response['id'];
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => LeaguePage(
//                                   idLeague: idLowerLeague,
//                                 ),
//                               ),
//                             );
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('No lower league found'),
//                               ),
//                             );
//                           }
//                         } on PostgrestException catch (error) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                   'Error fetching league: ${error.message}'),
//                             ),
//                           );
//                         }
//                       }
//                     },
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Icon(
//                           Icons.arrow_circle_right, // Changed the icon
//                           color: level == 1
//                               ? Colors.blueGrey
//                               : Colors.green, // Changed the icon color
//                           size: 32, // Increased the icon size
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                             'Right (${number + 1 > pow(2, level - 1) ? 1 : number + 1}/${pow(2, level - 1)})'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),

//         /// Lower Leagues
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             InkWell(
//               onTap: () async {
//                 try {
//                   final response = await supabase
//                       .from('leagues')
//                       .select('id')
//                       .eq('id_upper_league', id)
//                       .gt('id', 0)
//                       .limit(1)
//                       .single();

//                   if (response['error'] != null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                             'Error fetching league: ${response['error']['message']}'),
//                       ),
//                     );
//                   } else if (response['id'] != null) {
//                     print(response['id']);
//                     final idLowerLeague = response['id'];
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LeaguePage(
//                           idLeague: idLowerLeague,
//                         ),
//                       ),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('No lower league found'),
//                       ),
//                     );
//                   }
//                 } on PostgrestException catch (error) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error fetching league: ${error.message}'),
//                     ),
//                   );
//                 }
//               },
//               child: Row(
//                 children: [
//                   Text('Left Lower League'),
//                   SizedBox(width: 6),
//                   Icon(
//                     Icons.arrow_circle_down, // Changed the icon
//                     color: Colors.green, // Changed the icon color
//                     size: 32, // Increased the icon size
//                   ),
//                 ],
//               ),
//             ),
//             InkWell(
//               onTap: () async {
//                 try {
//                   final response = await supabase
//                       .from('leagues')
//                       .select('id')
//                       .eq('id_upper_league', id)
//                       .gt('id', 0)
//                       .limit(1)
//                       .single();

//                   if (response['error'] != null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                             'Error fetching league: ${response['error']['message']}'),
//                       ),
//                     );
//                   } else if (response['id'] != null) {
//                     print(response['id']);
//                     final idLowerLeague = response['id'];
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LeaguePage(
//                           idLeague: -idLowerLeague,
//                         ),
//                       ),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('No lower league found'),
//                       ),
//                     );
//                   }
//                 } on PostgrestException catch (error) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error fetching league: ${error.message}'),
//                     ),
//                   );
//                 }
//               },
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.arrow_circle_down, // Changed the icon
//                     color: Colors.green, // Changed the icon color
//                     size: 32, // Increased the icon size
//                   ),
//                   const SizedBox(width: 6),
//                   Text('Right Lower League'),
//                 ],
//               ),
//             ),
//           ],
//         )
//       ],
//     );
//   }
// }
