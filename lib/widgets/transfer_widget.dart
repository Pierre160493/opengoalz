// import 'dart:math';

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:opengoalz/classes/player/player.dart';
// import 'package:opengoalz/constants.dart';
// import 'package:opengoalz/global_variable.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class PlayerTransferTile extends StatelessWidget {
//   final Player player;
//   // final Function() onBidCompleted; // Define callback function

//   const PlayerTransferTile({
//     Key? key,
//     required this.player,
//     // required this.onBidCompleted, // Receive callback function
//   }) : super(key: key);

//   Stream<List<Map>> _getTransferBidsStream() {
//     return supabase
//         .from('transfers_bids')
//         .stream(primaryKey: ['id'])
//         .eq('id_player', player.id)
//         .order('created_at', ascending: true)
//         .map((maps) => maps
//             .map((map) => {
//                   'id': map['id'],
//                   'id_player': map['id_player'],
//                   'created_at': map['created_at'],
//                   'id_transfer': map['id_transfer'],
//                   'amount': map['amount'],
//                   'id_club': map['id_club'],
//                   'name_club': map['name_club'],
//                 })
//             .toList());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.blueGrey),
//       ),
//       child: ExpansionTile(
//         leading: Icon(
//           icon_transfers,
//           size: 30,
//           color: Colors.green,
//         ),
//         title: Row(
//           children: [
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Colors.blueGrey,
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       player.id_club_last_transfer_bid != null
//                           ? '${player.name_club_last_transfer_bid}'
//                           : 'No bids yet',
//                     ),
//                     Text(
//                       NumberFormat('#,###').format(
//                         player.amount_last_transfer_bid,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (player.id_club !=
//                 Provider.of<SessionProvider>(context).selectedClub.id_club)
//               IconButton(
//                 icon: const Icon(
//                   Icons.arrow_circle_up_outlined,
//                   size: 24,
//                   color: Colors.green,
//                 ),
//                 onPressed: () {
//                   _BidPlayer(context, player);
//                 },
//               ),
//           ],
//         ),
//         subtitle: Row(
//           children: [
//             StreamBuilder<int>(
//               stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
//               builder: (context, snapshot) {
//                 final remainingTime =
//                     player.date_sell!.difference(DateTime.now());
//                 final daysLeft = remainingTime.inDays;
//                 final hoursLeft = remainingTime.inHours.remainder(24);
//                 final minutesLeft = remainingTime.inMinutes.remainder(60);
//                 final secondsLeft = remainingTime.inSeconds.remainder(60);

//                 return Row(
//                   children: [
//                     Icon(Icons.timer_outlined),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           DateFormat('EEE d HH:mm', 'en_US')
//                               .format(player.date_sell!),
//                         ),
//                         Row(
//                           children: [
//                             if (daysLeft > 0)
//                               Text(
//                                 ' ${daysLeft}d, ',
//                                 style: const TextStyle(
//                                   color: Colors.red,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             Text(
//                               '${hoursLeft}h${minutesLeft}m${secondsLeft}s',
//                               style: const TextStyle(
//                                 color: Colors.red,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//         children: <Widget>[
//           Text('Bids History'),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: StreamBuilder<List<Map>>(
//               stream: _getTransferBidsStream(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else {
//                   final bids = snapshot.data ?? [];
//                   List<FlSpot> chartData = [];
//                   bids.forEach((bid) {
//                     double amount = bid['amount'].toDouble();
//                     DateTime createdAt = DateTime.parse(bid['created_at']);
//                     chartData.add(FlSpot(
//                       createdAt.millisecondsSinceEpoch.toDouble(),
//                       amount,
//                     ));
//                   });
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       AspectRatio(
//                         aspectRatio: 1.7,
//                         child: LineChart(
//                           LineChartData(
//                             lineBarsData: [
//                               LineChartBarData(
//                                 spots: chartData,
//                                 color: Colors.green,
//                                 barWidth: 4,
//                                 isStrokeCapRound: true,
//                                 belowBarData: BarAreaData(show: true),
//                               ),
//                             ],
//                             borderData: FlBorderData(
//                               border: Border.all(
//                                 color: Colors.green.withOpacity(0.5),
//                                 width: 1,
//                               ),
//                             ),
//                             minX: chartData.first.x,
//                             maxX: player.date_sell!.millisecondsSinceEpoch
//                                 .toDouble(),
//                             minY: 0,
//                             maxY: chartData.map((spot) => spot.y).reduce(
//                                     (value, element) =>
//                                         value > element ? value : element) *
//                                 1.2,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children:
//                             bids.asMap().entries.toList().reversed.map((entry) {
//                           final index = entry.key;
//                           final bid = entry.value;
//                           return ListTile(
//                             title: Text(
//                               '${bid['name_club']}: ${NumberFormat('#,###').format(bid['amount'])}',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             subtitle: Row(
//                               children: [
//                                 const Icon(Icons.timer_outlined),
//                                 Text(
//                                   ' ${DateFormat('EEE d HH:mm:ss', 'en_US').format(DateTime.parse(bid['created_at']))}',
//                                   style: const TextStyle(
//                                     fontStyle: FontStyle.italic,
//                                     color: Colors.blueGrey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             leading: Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.blue,
//                               ),
//                               alignment: Alignment.center,
//                               child: Text(
//                                 (index + 1).toString(),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             trailing: const Icon(
//                               Icons.arrow_forward_ios,
//                               color: Colors.blue,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ],
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _BidPlayer(BuildContext context, Player player) async {
//     // Checks
//     if (player.date_sell == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               'ERROR: Player ${player.first_name} ${player.last_name.toUpperCase()} doesn\'t seem to be for sale'),
//         ),
//       );
//       return;
//     } else if (DateTime.now().isAfter(player.date_sell!)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               'Player ${player.first_name} ${player.last_name.toUpperCase()} transfer\'s deadline is reached, bidding is over... '),
//         ),
//       );
//       return;
//     }

//     var date_sell = DateTime.now()
//         .add(const Duration(minutes: 5)); // Calculate the new date_sell
//     var min_bid = max(
//         player.amount_last_transfer_bid! +
//             1000, // We either add 1000 or 1% rounded to be clean
//         (player.amount_last_transfer_bid! * 1.02 / 1000).round() * 1000);

//     final TextEditingController _priceController = TextEditingController(
//         text: NumberFormat('####')
//             .format(min_bid)); // Initialize with current bid + offset

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//               'Place a bid on ${player.first_name} ${player.last_name.toUpperCase()}'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                   'Current maximum bid: ${NumberFormat('#,###').format(player.amount_last_transfer_bid)}'),
//               SizedBox(
//                 height: 6.0,
//               ),
//               Text(
//                 'min: ${NumberFormat('#,###').format(min_bid)} [${(100 * (min_bid - player.amount_last_transfer_bid!) / player.amount_last_transfer_bid!).toStringAsFixed(2)}% increase]',
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _priceController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'Please enter the value of your bid',
//                 ),
//               ),
//               Text(
//                   'Available cash: ${NumberFormat('#,###').format(Provider.of<SessionProvider>(context, listen: false).selectedClub.cash_available)}'),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(context).pop(); // Close the dialog
//                 try {
//                   int? newBid = int.tryParse(_priceController.text);
//                   if (newBid == null || newBid < min_bid) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                             'Please enter a valid number for minimum price (should be greater or equal to ${_priceController})'),
//                       ),
//                     );
//                     return;
//                   }
//                   await supabase.from('transfers_bids').insert({
//                     'amount': newBid,
//                     'id_player': player.id,
//                     'id_club':
//                         Provider.of<SessionProvider>(context, listen: false)
//                             .selectedClub
//                             .id_club,
//                     'name_club':
//                         Provider.of<SessionProvider>(context, listen: false)
//                             .selectedClub
//                             .club_name,
//                   });

//                   if (date_sell.isAfter(player.date_sell!)) {
//                     await supabase.from('players').update({
//                       'date_sell': date_sell.toIso8601String()
//                     }).match({'id': player.id});
//                   }
//                 } on PostgrestException catch (error) {
//                   print('testPG aqui');
//                   print(error);
//                   Fluttertoast.showToast(
//                     msg: "Your message here",
//                     toastLength: Toast.LENGTH_SHORT,
//                     gravity: ToastGravity.BOTTOM,
//                     timeInSecForIosWeb: 1,
//                     backgroundColor: Colors.red,
//                     textColor: Colors.white,
//                     fontSize: 16.0,
//                   );
//                   // ScaffoldMessenger.of(context).showSnackBar(
//                   //   SnackBar(
//                   //     content: Text(error.code!),
//                   //   ),
//                   // );
//                 }
//                 // After bidding is completed, call the callback function
//                 // onBidCompleted(); // Trigger refresh
//               },
//               child: const Text('Confirm'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
