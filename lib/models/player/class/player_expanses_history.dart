part of 'player.dart';

extension PlayerExpansesHistory on Player {
  void showPlayerExpansesHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Player Expanses History'),
          content: getPlayerExpansesHistory(context),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget getPlayerExpansesHistory(BuildContext context) {
    Stream<List<Map>> _expansesStream = supabase
        .from('players_expanses')
        .stream(primaryKey: ['id'])
        .eq('id_player', id)
        .order('created_at', ascending: true)
        .map((maps) => maps
            .map((map) => {
                  // 'id': map['id'],
                  'created_at': map['created_at'],
                  // 'id_player': map['id_player'],
                  'expanses': map['expanses'],
                })
            .toList());

    return StreamBuilder<List<Map>>(
      stream: _expansesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (!snapshot.hasData) {
          return Text('Error: No data');
        }
        final historyData = snapshot.data!;

        // Create a list of FlSpot
        final data = historyData.map((item) {
          final DateTime dateEvent = DateTime.parse(item['created_at']);
          final double expanses = item['expanses'].toDouble();
          return FlSpot(dateEvent.millisecondsSinceEpoch.toDouble(), expanses);
        }).toList();

        return Container(
          height: 600,
          width: 600,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                ),
              ],
              minY: 0,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                    axisNameWidget: Text('Time'),
                    sideTitles: SideTitles(showTitles: true)),
                leftTitles: AxisTitles(
                    axisNameWidget: Text('Expanses'),
                    sideTitles: SideTitles(showTitles: true)),
              ),
              // gridData: FlGridData(show: false),
              // borderData: FlBorderData(show: false),
            ),
          ),
        );
      },
    );
  }
}
