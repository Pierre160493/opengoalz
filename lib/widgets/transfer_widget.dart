import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PlayerTransferTile extends StatelessWidget {
  final Player player;

  const PlayerTransferTile({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bids = player.transferBids;
    List<FlSpot> chartData = [];
    bids.forEach((bid) {
      double amount = bid.amount.toDouble();
      DateTime createdAt = bid.createdAt;
      chartData.add(FlSpot(
        createdAt.millisecondsSinceEpoch.toDouble(),
        amount,
      ));
    });
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueGrey),
      ),
      child: ExpansionTile(
        leading: Icon(
          icon_transfers,
          size: 30,
          color: Colors.green,
        ),
        title: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueGrey,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(player.transferBids.last.nameClub),
                    Text(player.transferBids.last.amount.toString()),
                  ],
                ),
              ),
            ),
            if (player.idClub !=
                Provider.of<SessionProvider>(context).selectedClub.id_club)
              IconButton(
                icon: Icon(
                  Icons.arrow_circle_up_outlined,
                  size: 24,
                  color: Colors.green,
                ),
                onPressed: () {
                  _BidPlayer(context, player);
                },
              ),
          ],
        ),
        subtitle: Row(
          children: [
            StreamBuilder<int>(
              stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
              builder: (context, snapshot) {
                final remainingTime =
                    player.dateSell!.difference(DateTime.now());
                final daysLeft = remainingTime.inDays;
                final hoursLeft = remainingTime.inHours.remainder(24);
                final minutesLeft = remainingTime.inMinutes.remainder(60);
                final secondsLeft = remainingTime.inSeconds.remainder(60);

                return Row(
                  children: [
                    Icon(Icons.timer_outlined),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE d HH:mm', 'en_US')
                              .format(player.dateSell!),
                        ),
                        Row(
                          children: [
                            if (daysLeft > 0)
                              Text(
                                ' ${daysLeft}d, ',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Text(
                              '${hoursLeft}h${minutesLeft}m${secondsLeft}s',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        children: <Widget>[
          Text('Bids History'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AspectRatio(
                //   aspectRatio: 1.7,
                //   child: LineChart(
                //     LineChartData(
                //       lineBarsData: [
                //         LineChartBarData(
                //           spots: chartData,
                //           color: Colors.green,
                //           barWidth: 4,
                //           isStrokeCapRound: true,
                //           belowBarData: BarAreaData(show: true),
                //         ),
                //       ],
                //       borderData: FlBorderData(
                //         border: Border.all(
                //           color: Colors.green.withOpacity(0.5),
                //           width: 1,
                //         ),
                //       ),
                //       minX: chartData.first.x,
                //       maxX: player.date_sell!.millisecondsSinceEpoch.toDouble(),
                //       minY: 0,
                //       maxY: chartData.map((spot) => spot.y).reduce(
                //               (value, element) =>
                //                   value > element ? value : element) *
                //           1.2,
                //     ),
                //   ),
                // ),
                // SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: bids.asMap().entries.map((entry) {
                    final index = entry.key;
                    final bid = entry.value;
                    return ListTile(
                      title: Text(
                        '${bid.nameClub}: ${NumberFormat('#,###').format(bid.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.timer_outlined),
                          Text(
                            ' ${DateFormat('EEE d HH:mm:ss', 'en_US').format(bid.createdAt)}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _BidPlayer(BuildContext context, Player player) async {
    if (player.dateSell == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'ERROR: Player ${player.firstName} ${player.lastName.toUpperCase()} doesn\'t seem to be for sale'),
        ),
      );
      return;
    } else if (DateTime.now().isAfter(player.dateSell!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Player ${player.firstName} ${player.lastName.toUpperCase()} transfer\'s deadline is reached, bidding is over... '),
        ),
      );
      return;
    }

    var date_sell = DateTime.now().add(const Duration(minutes: 5));
    var min_bid = 0;

    final TextEditingController _priceController =
        TextEditingController(text: NumberFormat('####').format(min_bid));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Place a bid on ${player.firstName} ${player.lastName.toUpperCase()}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current maximum bid: '),
              SizedBox(height: 6.0),
              Text('min: % increase]'),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Please enter the value of your bid',
                ),
              ),
              Text(
                  'Available cash: ${NumberFormat('#,###').format(Provider.of<SessionProvider>(context, listen: false).selectedClub.cash_available)}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  int? newBid = int.tryParse(_priceController.text);
                  if (newBid == null || newBid < min_bid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Please enter a valid number for minimum price (should be greater or equal to ${_priceController.text})'),
                      ),
                    );
                    return;
                  }
                  await supabase.from('transfers_bids').insert({
                    'amount': newBid,
                    'id_player': player.id,
                    'id_club':
                        Provider.of<SessionProvider>(context, listen: false)
                            .selectedClub
                            .id_club,
                    'name_club':
                        Provider.of<SessionProvider>(context, listen: false)
                            .selectedClub
                            .name_club,
                  });

                  if (date_sell.isAfter(player.dateSell!)) {
                    await supabase.from('players').update({
                      'date_sell': date_sell.toIso8601String()
                    }).match({'id': player.id});
                  }
                } on PostgrestException catch (error) {
                  print('testPG aqui');
                  print(error);
                  Fluttertoast.showToast(
                    msg: "Your message here",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
