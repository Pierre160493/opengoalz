part of 'player.dart';

extension PlayerWidgetsActions on Player {
  Widget playerPopUpMenuItem(BuildContext context, int? index) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (index !=
            null) // Show the "Open Page" option only if multiple players currently displayed
          PopupMenuItem<String>(
            value: 'Open Page',
            child: Tooltip(
              message: 'Open ${getFullName()}\'s page',
              waitDuration: const Duration(seconds: 2),
              child: ListTile(
                leading: Icon(Icons.open_in_new, color: Colors.green),
                title: Text('Open Page'),
              ),
            ),
          ),
        if (dateBidEnd == null) ...[
          PopupMenuItem<String>(
            value: 'Sell',
            child: Tooltip(
              message: 'Put ${getFullName()} in auction for sale',
              waitDuration: const Duration(seconds: 2),
              child: ListTile(
                leading: Icon(iconTransfers, color: Colors.red),
                title: Text('Sell'),
              ),
            ),
          ),
          PopupMenuItem<String>(
            value: 'Fire',
            child: Tooltip(
              message: 'Fire ${getFullName()} from your club',
              waitDuration: const Duration(seconds: 2),
              child: ListTile(
                leading: Icon(iconLeaveClub, color: Colors.red),
                title: Text('Fire'),
              ),
            ),
          )
        ] else
          PopupMenuItem<String>(
            value: 'Unfire',
            child: Tooltip(
              message: 'Unfire ${getFullName()} from your club',
              waitDuration: const Duration(seconds: 2),
              child: ListTile(
                leading: Icon(Icons.cancel, color: Colors.green),
                title: Text('Unfire'),
              ),
            ),
          ),
        // Add more PopupMenuItems for additional actions
      ],
      onSelected: (String value) async {
        // Handle selected action here
        switch (value) {
          /// Open the player's page
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

          /// Sell the player
          case 'Sell':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SellFirePlayerDialogBox(idPlayer: this.id);
              },
            );
            break;

          /// Fire the player
          case 'Fire':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SellFirePlayerDialogBox(
                    idPlayer: this.id, firePlayer: true);
              },
            );
            break;

          /// Unfire the player
          case 'Unfire':
            try {
              await supabase
                  .from('players')
                  .update({'date_bid_end': null}).match({'id': id});

              context.showSnackBarSuccess(
                '${firstName} ${lastName.toUpperCase()} is happy to stay in your club !',
              );
            } on PostgrestException catch (error) {
              context.showSnackBarPostgreSQLError(error.message);
            } on Exception catch (error) {
              context.showSnackBarError(error.toString());
            }

            break;
          // Add cases for additional actions if needed
        }
      },
      child: Icon(Icons.pending_actions_outlined, color: Colors.green),
    );
  }
}
