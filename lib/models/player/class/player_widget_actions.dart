part of 'player.dart';

extension PlayerWidgetsActions on Player {
  Widget playerPopUpMenuItem(BuildContext context, int? index) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (index !=
            null) // Show the "Open Page" option only if multiple players currently displayed
          const PopupMenuItem<String>(
            value: 'Open Page',
            child: ListTile(
              leading: Icon(Icons.open_in_new),
              title: Text('Open Player\'s Page'),
            ),
          ),
        if (dateBidEnd == null) ...[
          const PopupMenuItem<String>(
            value: 'Sell',
            child: ListTile(
              leading: Icon(iconTransfers),
              title: Text('Sell'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'Fire',
            child: ListTile(
              leading: Icon(iconLeaveClub),
              title: Text('Fire'),
            ),
          )
        ] else
          const PopupMenuItem<String>(
            value: 'Unfire',
            child: ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Unfire'),
            ),
          ),
        // Add more PopupMenuItems for additional actions
      ],
      onSelected: (String value) {
        // Handle selected action here
        switch (value) {
          case 'Open Page':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayersPage(
                  playerSearchCriterias: PlayerSearchCriterias(idPlayer: [id]),
                ),
              ),
            );
            break;
          case 'Sell':
            _SellPlayer(context, false); // Sell Player
            break;
          case 'Fire':
            _SellPlayer(context, true); // Fire Player
            break;
          case 'Unfire':
            _UnFirePlayer(context); // Unfire Player
            break;
          // Add cases for additional actions if needed
        }
      },
      child: Icon(Icons.pending_actions_outlined),
    );
  }

  Future<void> _SellPlayer(BuildContext context, bool firePlayer) async {
    final TextEditingController _priceController =
        TextEditingController(text: '0'); // Initialize with default value
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    DateTime selectedDate =
        DateTime.now().add(Duration(days: 7)); // Default to now + 7 days
    TimeOfDay selectedTime = TimeOfDay.now(); // Default to current time

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              '${firePlayer ? 'Fire' : 'Sell'} ${firstName} ${lastName.toUpperCase()}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (firePlayer == false) ...[
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.blueGrey, width: 1.0),
                  ),
                  leading: Icon(iconMoney),
                  title: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Allow only digits
                    ],
                    decoration: InputDecoration(
                      labelText: 'Start price',
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
                formSpacer6
              ],
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Colors.blueGrey, width: 1.0),
                ),
                leading: Icon(iconCalendar),
                title: Text(
                  DateFormat('EEE dd MMM HH:mm').format(selectedDate),
                ),
                subtitle: Text(
                  'Date and time when the bid will end',
                  style: TextStyle(
                      color: Colors.blueGrey, fontStyle: FontStyle.italic),
                ),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().add(Duration(days: 3)),
                    lastDate: DateTime.now().add(Duration(days: 14)),
                  );
                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      initialEntryMode: TimePickerEntryMode.input,
                    );
                    if (pickedTime != null) {
                      selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      selectedTime = pickedTime;
                    }
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            /// Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Row(
                children: [
                  Icon(iconCancel, color: Colors.red),
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
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please enter a valid number for minimum price (should be a positive integer)'),
                      ),
                    );
                    return;
                  }
                  if (firePlayer) {
                    minimumPrice = -1;
                  }

                  // Validate the selected date
                  if (selectedDate
                          .isBefore(DateTime.now().add(Duration(days: 3))) ||
                      selectedDate
                          .isAfter(DateTime.now().add(Duration(days: 14)))) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please select a valid date between 3 and 14 days from now'),
                      ),
                    );
                    return;
                  }

                  // Call the transfers_new_transfer function
                  await supabase.rpc('transfers_new_transfer', params: {
                    'inp_id_player': id,
                    'inp_amount': minimumPrice,
                    'inp_date_bid_end': selectedDate.toIso8601String(),
                  });

                  context.showSnackBarSuccess(
                      '${firstName} ${lastName.toUpperCase()} ' +
                          (firePlayer
                              ? 'has been put to transfer list and will be fired if no bids are received'
                              : 'has been put to transfer list'));
                } on PostgrestException catch (error) {
                  context.showSnackBarPostgreSQLError(error.message);
                } catch (error) {
                  context.showSnackBarError(error.toString());
                }
              },
              child: Row(
                children: [
                  Icon(iconSuccessfulOperation, color: Colors.green),
                  formSpacer3,
                  Text('Confirm'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _FirePlayer(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text(
              'Are you sure you want to fire ${firstName} ${lastName.toUpperCase()} ?'),
          actions: <Widget>[
            /// Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),

            /// Confirm Button
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Execute firing action if user confirms
                try {
                  DateTime dateFiring =
                      DateTime.now().add(const Duration(days: 7));
                  await supabase.from('players').update({
                    'date_firing': dateFiring.toIso8601String()
                  }).match({'id': id});
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                          '${firstName} ${lastName.toUpperCase()} has 7 days to pack his stuff and leave !'),
                    ),
                  );
                } on PostgrestException catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error.message),
                    ),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _UnFirePlayer(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await supabase.from('players').update({
        'date_firing': null // Set date_firing to null to "Unfire" the player
      }).match({'id': id});
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
              '${firstName} ${lastName.toUpperCase()} is happy to stay in your club !'),
        ),
      );
    } on PostgrestException catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.code!),
        ),
      );
    }
  }
}
