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

  bool _firePlayer = false;
  bool _isPriceValid = true;
  late bool _isDateValid;

  final TextEditingController _priceController =
      TextEditingController(text: '100'); // Initialize with default value
  final TextEditingController _dateController = TextEditingController();
  late DateTime _selectedDateTime;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeDateTime();
    _initializePlayerStream();
    _firePlayer = widget.firePlayer;
  }

  void _initializeDateTime() {
    _selectedDateTime = DateTime.now()
        .add(Duration(minutes: 5))
        .copyWith(second: 0, millisecond: 0, microsecond: 0);
    _isDateValid = true;
    _dateController.text =
        DateFormat('EEE dd MMM HH:mm').format(_selectedDateTime);
  }

  void _initializePlayerStream() {
    _playerStream = supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idPlayer)
        .map((maps) => maps.map((map) => Player.fromMap(map)).first)
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
  }

  @override
  void dispose() {
    _priceController.dispose();
    _dateController.dispose();
    _playerSubscription?.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context) async {
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
          _dateController.text =
              DateFormat('EEE dd MMM HH:mm').format(_selectedDateTime);
          _formKey.currentState?.validate();
        });
      }
    }
  }

  String? _validateDateTime(String? value) {
    _isDateValid = false;

    if (_selectedDateTime.isBefore(DateTime.now())) {
      return 'Date has passed already';
    }

    if (_selectedDateTime.isAfter(DateTime.now().add(Duration(days: 14)))) {
      return 'Date within the next 14 days';
    }

    _isDateValid = true;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_player == null) {
      return Center(child: CircularProgressIndicator());
    }

    final Player player = _player!;

    /// Sell Club Row
    final Row rowSellPlayer = Row(
      children: [
        Icon(iconTransfers, color: Colors.green),
        formSpacer6,
        Text('Sell '),
      ],
    );

    /// Leave Club Row
    final Row rowFirePlayer = Row(
      children: [
        Icon(iconLeaveClub, color: Colors.green),
        formSpacer6,
        Text('Fire '),
      ],
    );

    return AlertDialog(
      title: Row(
        children: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                _firePlayer = result == 'Fire';
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Sell',
                child: rowSellPlayer,
              ),
              PopupMenuItem<String>(
                value: 'Fire',
                child: rowFirePlayer,
              ),
            ],
            child: _firePlayer ? rowFirePlayer : rowSellPlayer,
          ),
          player.getPlayerNameToolTip(context),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Display the _priceController only if the player is gonna be sold
            if (_firePlayer == false)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                      color: _isPriceValid ? Colors.green : Colors.red,
                      width: 2.0),
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
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _isPriceValid ? Colors.green : Colors.red,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _isPriceValid ? Colors.green : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _isPriceValid ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        _isPriceValid = false;
                      });
                      return 'Please enter a price';
                    }
                    final int? price = int.tryParse(value);
                    if (price == null) {
                      setState(() {
                        _isPriceValid = false;
                      });
                      return 'Please enter a valid integer';
                    }
                    if (price < 100) {
                      setState(() {
                        _isPriceValid = false;
                      });
                      return 'Starting price should be at least 100';
                    }
                    setState(() {
                      _isPriceValid = true;
                    });
                    return null;
                  },
                  onChanged: (value) {
                    _formKey.currentState?.validate();
                  },
                ),
              ),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                    color: _isDateValid ? Colors.green : Colors.red,
                    width: 2.0),
              ),
              leading: Icon(iconCalendar),
              title: TextFormField(
                controller: _dateController,
                readOnly: true,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Bidding End Date',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isDateValid ? Colors.green : Colors.red,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isDateValid ? Colors.green : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isDateValid ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                onTap: () => _pickDateTime(context),
                validator: _validateDateTime,
              ),
              subtitle: tickingTimeWidget(_selectedDateTime),
            ),
          ],
        ),
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
              try {
                int? minimumPrice = int.tryParse(_priceController.text);
                if (minimumPrice == null || minimumPrice < 0) {
                  context.showSnackBarError(
                      'Please enter a valid number for minimum price (should be a positive integer)');
                  return;
                }
                if (_firePlayer) {
                  minimumPrice = 0;
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
                    (_firePlayer
                        ? 'has been put to transfer list and will be fired if no bids are received'
                        : 'has been put to transfer list'));
              } on PostgrestException catch (error) {
                context.showSnackBarPostgreSQLError(error.message);
              } catch (error) {
                context.showSnackBarError(error.toString());
              }
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Row(
              children: [
                _firePlayer
                    ? rowFirePlayer
                    : rowSellPlayer, // Display the correct icon
                formSpacer3,
                Text(player.getPlayerNameString()),
              ],
            ),
          ),
        ])
      ],
    );
  }
}
