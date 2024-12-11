import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/models/transfer_bid.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/widgets/tickingTime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SellFirePlayerDialogBox extends StatefulWidget {
  final int idPlayer;
  final bool firePlayer;
  SellFirePlayerDialogBox({required this.idPlayer, this.firePlayer = false});
  @override
  _SellFirePlayerDialogBoxState createState() =>
      _SellFirePlayerDialogBoxState();
}

class _SellFirePlayerDialogBoxState extends State<SellFirePlayerDialogBox> {
  Stream<Player> _playerStream = Stream.empty();
  StreamSubscription<Player>? _playerSubscription;
  Player? _player;

  final TextEditingController _priceController =
      TextEditingController(text: '100'); // Initialize with default value
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now().add(Duration(minutes: 5));

  @override
  void initState() {
    super.initState();

    _playerStream = supabase

        /// Fetch the player
        .from('players')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idPlayer)
        .map((maps) => maps.map((map) => Player.fromMap(map)).first)

        /// Fetch its club
        .switchMap((Player player) {
          if (player.idClub == null) {
            return Stream.value(player);
          }
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('id', player.idClub!)
              .map((maps) => maps.map((map) => Club.fromMap(map)).first)
              .map((Club club) {
                player.club = club;
                return player;
              });
        })

        /// Fetch its transfers bids
        .switchMap((Player player) {
          return supabase
              .from('transfers_bids')
              .stream(primaryKey: ['id'])
              .eq('id_player', player.id)
              .order('count_bid', ascending: true)
              .map((maps) =>
                  maps.map((map) => TransferBid.fromMap(map)).toList())
              .map((List<TransferBid> transfersBids) {
                player.transferBids.clear();
                player.transferBids.addAll(transfersBids);
                return player;
              });
        });

    _playerSubscription = _playerStream.listen((player) {
      setState(() {
        _player = player;
      });
    });

    _dateController.text = DateFormat('EEE dd MMM HH:mm')
        .format(_selectedDateTime); // Initialize the date controller
  }

  @override
  void dispose() {
    _priceController.dispose();
    _dateController.dispose();
    _playerSubscription?.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_player == null) {
      return Center(child: CircularProgressIndicator());
    }

    final Player player = _player!;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return AlertDialog(
        title: Row(
          children: [
            Text('${widget.firePlayer ? 'Fire' : 'Sell'} '),
            player.getPlayerNameToolTip(context),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Display the _priceController only if the player is gonna be sold
            if (widget.firePlayer == false)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Colors.blueGrey, width: 1.0),
                ),
                leading:
                    Icon(iconMoney, size: iconSizeMedium, color: Colors.green),
                title: TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  ],
                  decoration: InputDecoration(
                    labelText: 'Starting price',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    final int? price = int.tryParse(value);
                    if (price == null) {
                      return 'Please enter a valid integer';
                    }
                    return null;
                  },
                ),
                subtitle: Text(
                  'Enter the starting price',
                  style: TextStyle(
                      color: Colors.blueGrey, fontStyle: FontStyle.italic),
                ),
              ),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: Colors.blueGrey, width: 1.0),
              ),
              leading: Icon(iconCalendar),
              title: TextFormField(
                controller: _dateController,
                readOnly: true,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Bidding End Date',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime,
                    firstDate: DateTime.now().add(Duration(minutes: 5)),
                    lastDate: DateTime.now().add(Duration(days: 14)),
                  );
                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                      initialEntryMode: TimePickerEntryMode.input,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        _dateController.text = DateFormat('EEE dd MMM HH:mm')
                            .format(_selectedDateTime);
                      });
                    }
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date and time';
                  }
                  final DateTime? date =
                      DateFormat('EEE dd MMM HH:mm').parse(value, true);
                  if (date == null) {
                    return 'Please enter a valid date and time';
                  }
                  if (date.isBefore(DateTime.now().add(Duration(minutes: 5)))) {
                    return 'Please select a date and time at least 5 minutes from now';
                  }
                  if (date.isAfter(DateTime.now().add(Duration(days: 14)))) {
                    return 'Please select a date and time within the next 14 days';
                  }
                  return null;
                },
              ),
              subtitle: tickingTimeWidget(_selectedDateTime),
            ),
          ],
        ),
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            /// Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  formSpacer3,
                  Text('Cancel'),
                ],
              ),
            ),

            /// Confirm button
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                try {
                  int? minimumPrice = int.tryParse(_priceController.text);
                  if (minimumPrice == null || minimumPrice < 0) {
                    context.showSnackBarError(
                        'Please enter a valid number for minimum price (should be a positive integer)');
                    return;
                  }
                  // if (firePlayer) {
                  //   minimumPrice = 0;
                  // }

                  // Validate the selected date
                  if (
                      // selectedDate.isBefore(
                      //       DateTime.now().add(Duration(minutes: 30))) ||
                      _selectedDateTime
                          .isAfter(DateTime.now().add(Duration(days: 14)))) {
                    context.showSnackBarError(
                        'Please select a valid date between XXX and 14 days from now');
                    return;
                  }

                  // Call the transfers_new_transfer function
                  await supabase.rpc('transfers_handle_new_bid', params: {
                    'inp_id_player': player.id,
                    'inp_id_club_bidder':
                        Provider.of<SessionProvider>(context, listen: false)
                            .user!
                            .selectedClub
                            ?.id,
                    'inp_amount': minimumPrice,
                    'inp_date_bid_end':
                        _selectedDateTime.toUtc().toIso8601String(),
                  });

                  context.showSnackBarSuccess('${player.getPlayerNameString()} ' +
                      // (firePlayer
                      //     ? 'has been put to transfer list and will be fired if no bids are received'
                      //     : 'has been put to transfer list'));
                      'has been put to transfer list');
                } on PostgrestException catch (error) {
                  context.showSnackBarPostgreSQLError(error.message);
                } catch (error) {
                  context.showSnackBarError(error.toString());
                }
              },
              child: Row(
                children: [
                  Icon(Icons.gavel, color: Colors.green),
                  formSpacer3,
                  Text('Sell  ${player.getPlayerNameString()}'),
                ],
              ),
            ),
          ])
        ],
      );
    });
  }
}
