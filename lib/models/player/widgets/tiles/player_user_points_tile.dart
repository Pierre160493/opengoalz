import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/player_user_points_button.dart';
import 'package:opengoalz/widgets/graph_widget.dart';

class PlayerUserPointsTile extends StatelessWidget {
  final Player player;

  const PlayerUserPointsTile({Key? key, required this.player})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// If the player is not an embodied player
    if (player.userName == null) {
      return ListTile(
        shape: shapePersoRoundedBorder(),
        leading: Icon(
          iconUser,
          size: iconSizeMedium,
          color: Colors.blue,
        ),
        title: Text(
          'Player not embodied',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'No user assigned',
          style: styleItalicBlueGrey,
        ),
      );
    }

    return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Icon(
        iconUser,
        size: iconSizeMedium,
        color: colorIsMine,
      ),
      title: Row(
        children: [
          Text('User training points available: '),
          Text(
            player.userPointsAvailable.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: player.userPointsAvailable < 0 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text('User training points used: ', style: styleItalicBlueGrey),
          TextButton(
            child: Text(
              player.userPointsUsed.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final fieldsToPlot = [
                    'user_points_available',
                    'user_points_used',
                  ];
                  return FutureBuilder<List<Map>>(
                    future: supabase
                        .from('players_history_stats')
                        .select('created_at, ${fieldsToPlot.join(", ")}')
                        .eq('id_player', player.id)
                        .order('created_at', ascending: true)
                        .then((response) => response),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return loadingCircularAndText(
                            'Loading player history...');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('Error: No data');
                      }
                      final historyData = snapshot.data!;

                      // Add a calculated column for total points
                      for (var item in historyData) {
                        item['total_points'] =
                            (item['user_points_available'] as num) +
                                (item['user_points_used'] as num);
                      }

                      // Check for null values in the required fields
                      for (var field in fieldsToPlot) {
                        if (historyData.any((item) => item[field] == null)) {
                          return AlertDialog(
                            title: Text('Data Error'),
                            content: Text(
                              'Error: Missing data for field "$field".',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          );
                        }
                      }

                      final chartData = ChartData(
                        title: 'User Points History (Total, Available, Used)',
                        yValues: [
                          historyData
                              .map((item) =>
                                  (item['total_points'] as num).toDouble())
                              .toList(),
                          ...fieldsToPlot.map((field) {
                            return historyData
                                .map((item) => (item[field] as num).toDouble())
                                .toList();
                          }),
                        ],
                        typeXAxis: XAxisType.weekHistory,
                      );

                      return ChartDialogBox(chartData: chartData);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      trailing: PlayerUserPointsButton(player: player),
    );
  }
}
