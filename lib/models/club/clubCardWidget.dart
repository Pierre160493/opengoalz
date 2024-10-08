part of 'club.dart';

extension ClubCardWidget on Club {
  Widget getClubCard(BuildContext context, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24), // Adjust border radius as needed
        side: const BorderSide(
          color: Colors.blueGrey, // Border color
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              Provider.of<SessionProvider>(context, listen: false)
                  .providerSetSelectedClub(id);
            },
            leading: CircleAvatar(
              backgroundColor: (id ==
                      Provider.of<SessionProvider>(context)
                          .user!
                          .selectedClub
                          ?.id)
                  ? Colors.green
                  : Colors.blueGrey,
              child: Text(
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
            hoverColor: Colors.brown,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getClubName(context),
                getLastResultsWidget(context),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getRankingWidget(context),
                getMultiverseWidget(context, idMultiverse),
              ],
            ),
          ),
          if (id ==
              Provider.of<SessionProvider>(context).user!.selectedClub?.id)
            Column(
              children: [
                const SizedBox(height: 6),
                getQuickAccessWidget(context, id),
                const SizedBox(height: 6),
              ],
            ),
        ],
      ),
    );
  }
}
