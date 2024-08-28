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
        if (dateSell == null)
          if (dateFiring == null) ...[
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
                  inputCriteria: {
                    'Players': [id]
                  },
                ),
              ),
            );
            break;
          case 'Sell':
            _SellPlayer(context); // Sell Player
            break;
          case 'Fire':
            _FirePlayer(context); // Fire Player
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

  Future<void> _SellPlayer(BuildContext context) async {
    final TextEditingController _priceController =
        TextEditingController(text: '0'); // Initialize with default value

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Put to transfer list'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the starting price for ${firstName} ${lastName.toUpperCase()}',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Start price',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            /// Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
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
                  await supabase.from('transfers_bids').insert({
                    'amount': minimumPrice,
                    'id_player': id,
                    'id_club':
                        Provider.of<SessionProvider>(context, listen: false)
                            .user!
                            .selectedClub
                            .id,
                  });
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                          '${firstName} ${lastName.toUpperCase()} has been put to transfer list'),
                    ),
                  );
                } on PostgrestException catch (error) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(error.message),
                    ),
                  );
                } catch (error) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('An unexpected error occurred.'),
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
