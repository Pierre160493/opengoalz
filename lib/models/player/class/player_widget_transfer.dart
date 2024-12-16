// part of 'player.dart';

// extension PlayerWidgetTransfer on Player {
//   Widget playerTransferWidget(BuildContext context) {
//     // final bids = transferBids;
//     // List<FlSpot> chartData = [];
//     // bids.forEach((bid) {
//     //   double amount = bid.amount.toDouble();
//     //   DateTime createdAt = bid.createdAt;
//     //   chartData.add(FlSpot(
//     //     createdAt.millisecondsSinceEpoch.toDouble(),
//     //     amount,
//     //   ));
//     // });
//     return ListTile(
//       shape: RoundedRectangleBorder(
//         borderRadius:
//             BorderRadius.circular(12), // Adjust border radius as needed
//         side: const BorderSide(
//           color: Colors.blueGrey, // Border color
//         ),
//       ),
//       leading: Icon(
//         iconTransfers,
//         size: iconSizeMedium,
//         color: Colors.green,
//       ),
//       title: Row(
//         children: [
//           Text(
//             transferBids.length == 0
//                 ? 'Starting price: '
//                 : '${transferBids.last.nameClub}: ',
//           ),
//           formSpacer6,
//           Text(
//             transferPrice!.abs().toString(),
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.green, // Highlight the amount in a different color
//             ),
//           ),
//         ],
//       ),
//       subtitle: Row(
//         children: [
//           StreamBuilder<int>(
//             stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
//             builder: (context, snapshot) {
//               final remainingTime = dateBidEnd!.difference(DateTime.now());
//               final daysLeft = remainingTime.inDays;
//               final hoursLeft = remainingTime.inHours.remainder(24);
//               final minutesLeft = remainingTime.inMinutes.remainder(60);
//               final secondsLeft = remainingTime.inSeconds.remainder(60);

//               return Tooltip(
//                 message: 'Deadline: ' +
//                     DateFormat('EEE d MMM HH:mm', 'en_US').format(dateBidEnd!),
//                 child: Row(
//                   children: [
//                     Icon(Icons.timer_outlined, color: Colors.blueGrey),
//                     Row(
//                       children: [
//                         // if (daysLeft > 0)
//                         Text(
//                           ' ${daysLeft > 0 ? '${daysLeft}d,' : ''} ${hoursLeft > 0 ? '${hoursLeft}h' : ''}${minutesLeft > 0 ? '${minutesLeft}m' : ''}${secondsLeft}s',
//                           style: const TextStyle(
//                             color: Colors.red,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       onTap: () {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return PlayerTransferBidDialogBox(idPlayer: this.id);
//           },
//         );
//       },
//     );

//     // Container(
//     //   width: double.infinity,
//     //   decoration: BoxDecoration(
//     //     borderRadius: BorderRadius.circular(24),
//     //     border: Border.all(color: Colors.blueGrey),
//     //   ),
//     //   child: ExpansionTile(
//     //     leading: Icon(
//     //       iconTransfers,
//     //       size: 30,
//     //       color: Colors.green,
//     //     ),
//     //     title: Row(
//     //       children: [
//     //         Expanded(
//     //           child: Container(
//     //             width: double.infinity,
//     //             decoration: BoxDecoration(
//     //               border: Border.all(
//     //                 color: Colors.blueGrey,
//     //               ),
//     //               borderRadius: BorderRadius.circular(10),
//     //             ),
//     //             padding: EdgeInsets.symmetric(horizontal: 8),
//     //             child: Column(
//     //               crossAxisAlignment: CrossAxisAlignment.center,
//     //               children: [
//     //                 Text(transferBids.last.nameClub),
//     //                 Text(transferBids.last.amount.toString()),
//     //               ],
//     //             ),
//     //           ),
//     //         ),
//     //         if (idClub !=
//     //             Provider.of<SessionProvider>(context, listen: false).user!.selectedClub!.id)
//     //           IconButton(
//     //             icon: Icon(
//     //               Icons.arrow_circle_up_outlined,
//     //               size: 24,
//     //               color: Colors.green,
//     //             ),
//     //             onPressed: () {
//     //               _BidPlayer(context);
//     //             },
//     //           ),
//     //       ],
//     //     ),
//     //     subtitle: Row(
//     //       children: [
//     //         StreamBuilder<int>(
//     //           stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
//     //           builder: (context, snapshot) {
//     //             final remainingTime = dateBidEnd!.difference(DateTime.now());
//     //             final daysLeft = remainingTime.inDays;
//     //             final hoursLeft = remainingTime.inHours.remainder(24);
//     //             final minutesLeft = remainingTime.inMinutes.remainder(60);
//     //             final secondsLeft = remainingTime.inSeconds.remainder(60);

//     //             return Row(
//     //               children: [
//     //                 Icon(Icons.timer_outlined),
//     //                 Column(
//     //                   crossAxisAlignment: CrossAxisAlignment.center,
//     //                   children: [
//     //                     Text(
//     //                       DateFormat('EEE d HH:mm', 'en_US')
//     //                           .format(dateBidEnd!),
//     //                     ),
//     //                     Row(
//     //                       children: [
//     //                         if (daysLeft > 0)
//     //                           Text(
//     //                             ' ${daysLeft}d, ',
//     //                             style: const TextStyle(
//     //                               color: Colors.red,
//     //                               fontWeight: FontWeight.bold,
//     //                             ),
//     //                           ),
//     //                         Text(
//     //                           '${hoursLeft}h${minutesLeft}m${secondsLeft}s',
//     //                           style: const TextStyle(
//     //                             color: Colors.red,
//     //                             fontWeight: FontWeight.bold,
//     //                           ),
//     //                         ),
//     //                       ],
//     //                     ),
//     //                   ],
//     //                 ),
//     //               ],
//     //             );
//     //           },
//     //         ),
//     //       ],
//     //     ),
//     //     children: <Widget>[
//     //       Text('Bids History'),
//     //       Padding(
//     //         padding: EdgeInsets.symmetric(horizontal: 16),
//     //         child: Column(
//     //           crossAxisAlignment: CrossAxisAlignment.start,
//     //           children: [
//     //             // AspectRatio(
//     //             //   aspectRatio: 1.7,
//     //             //   child: LineChart(
//     //             //     LineChartData(
//     //             //       lineBarsData: [
//     //             //         LineChartBarData(
//     //             //           spots: chartData,
//     //             //           color: Colors.green,
//     //             //           barWidth: 4,
//     //             //           isStrokeCapRound: true,
//     //             //           belowBarData: BarAreaData(show: true),
//     //             //         ),
//     //             //       ],
//     //             //       borderData: FlBorderData(
//     //             //         border: Border.all(
//     //             //           color: Colors.green.withOpacity(0.5),
//     //             //           width: 1,
//     //             //         ),
//     //             //       ),
//     //             //       minX: chartData.first.x,
//     //             //       maxX: player.date_sell!.millisecondsSinceEpoch.toDouble(),
//     //             //       minY: 0,
//     //             //       maxY: chartData.map((spot) => spot.y).reduce(
//     //             //               (value, element) =>
//     //             //                   value > element ? value : element) *
//     //             //           1.2,
//     //             //     ),
//     //             //   ),
//     //             // ),
//     //             // SizedBox(height: 16),
//     //             Column(
//     //               crossAxisAlignment: CrossAxisAlignment.start,
//     //               children: bids.asMap().entries.map((entry) {
//     //                 final index = entry.key;
//     //                 final bid = entry.value;
//     //                 return ListTile(
//     //                   title: Text(
//     //                     '${bid.nameClub}: ${NumberFormat('#,###').format(bid.amount)}',
//     //                     style: TextStyle(fontWeight: FontWeight.bold),
//     //                   ),
//     //                   subtitle: Row(
//     //                     children: [
//     //                       Icon(Icons.timer_outlined),
//     //                       Text(
//     //                         ' ${DateFormat('EEE d HH:mm:ss', 'en_US').format(bid.createdAt)}',
//     //                         style: TextStyle(
//     //                           fontStyle: FontStyle.italic,
//     //                           color: Colors.blueGrey,
//     //                         ),
//     //                       ),
//     //                     ],
//     //                   ),
//     //                   leading: Container(
//     //                     width: 40,
//     //                     height: 40,
//     //                     decoration: BoxDecoration(
//     //                       shape: BoxShape.circle,
//     //                       color: Colors.blue,
//     //                     ),
//     //                     alignment: Alignment.center,
//     //                     child: Text(
//     //                       (index + 1).toString(),
//     //                       style: TextStyle(
//     //                         color: Colors.white,
//     //                         fontWeight: FontWeight.bold,
//     //                       ),
//     //                     ),
//     //                   ),
//     //                   trailing: Icon(
//     //                     Icons.arrow_forward_ios,
//     //                     color: Colors.blue,
//     //                   ),
//     //                 );
//     //               }).toList(),
//     //             ),
//     //           ],
//     //         ),
//     //       ),
//     //     ],
//     //   ),
//     // );
//   }
// }
