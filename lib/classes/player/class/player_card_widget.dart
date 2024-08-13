part of 'player.dart';

extension PlayerCardWidget on Player {
  Widget getPlayerCard(BuildContext context, int? index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24), // Adjust border radius as needed
        side: const BorderSide(
          color: Colors.blueGrey, // Border color
        ),
      ),
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            onTap: () {
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
            },
            leading: CircleAvatar(
              backgroundColor: (Provider.of<SessionProvider>(context)
                      .user!
                      .players
                      .any((Player player) => player.id == id))
                  ? Colors.purple
                  : null,
              child: index == null
                  ? Text('test NULL')
                  : Text(
                      (index + 1).toString(),
                    ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(24), // Adjust border radius as needed
              side: const BorderSide(
                color: Colors.blueGrey, // Border color
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getPlayerNames(context),
                getStatusRow(),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getClubNameClickable(context, null, idClub),
                multiverseWidget(multiverseSpeed),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
