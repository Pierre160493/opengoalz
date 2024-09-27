part of 'player.dart';

extension PlayerCardHistory on Player {
  Widget playerCardHistoryWidget(BuildContext context) {
    Stream<List<Map>> _historyStream = supabase
        .from('players_history')
        .stream(primaryKey: ['id'])
        .eq('id_player', id)
        .order('created_at', ascending: false)
        .map((maps) => maps
            .map((map) => {
                  'id': map['id'],
                  'created_at': map['created_at'],
                  'id_player': map['id_player'],
                  'description': map['description'],
                  'id_club': map['id_club'],
                })
            .toList());

    return StreamBuilder<List<Map>>(
      stream: _historyStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Extract history data from snapshot
          final historyData = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    final item = historyData[index];
                    final DateTime dateEvent =
                        DateTime.parse(item['created_at']);
                    // final double ageEvent =
                    //     dateEvent.difference(dateBirth).inDays /
                    //         (14 * 7 / multiverseSpeed);
                    final double ageEvent =
                        calculateAge(dateEvent, multiverseSpeed);
                    return ListTile(
                      title: Text(
                        item['description'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(
                            Icons.cake_outlined,
                            color: Colors.green,
                          ),
                          Text(
                            ' ${ageEvent.truncate()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(' years, '),
                          Text(
                            ((ageEvent - ageEvent.truncate()) * 112)
                                .floor()
                                .toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(' days '),
                          Icon(Icons.access_time_outlined, color: Colors.green),
                          Text(
                            '${DateFormat(' yyyy-MM-dd HH:mm').format(dateEvent)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      leading: Icon(
                        Icons.history_edu_outlined,
                        color: Colors.blueGrey,
                        size: 36,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                      ),
                      onTap: () {
                        // Add any action you want to perform when the tile is tapped
                      },
                    );
                  },
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        // By default, show a loading indicator
        return CircularProgressIndicator();
      },
    );
  }
}
