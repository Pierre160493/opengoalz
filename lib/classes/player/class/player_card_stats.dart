part of 'player.dart';

extension PlayerCardStats on Player {
  Widget playerCardStatsWidget(BuildContext context) {
    final features = [
      keeper,
      defense,
      playmaking,
      passes,
      winger,
      scoring,
      freekick,
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 6.0),
          ListTile(
            leading: Icon(
              Icons.query_stats,
              size: iconSizeMedium,
              color: Colors.green,
            ),
            title: Text('Training points: ${trainingPoints}'),
            subtitle: Text(
              'Gain training points thanks to the staff',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            trailing: trainingPoints >= 1
                ? InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: Text('What do you wish to increase ?'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      // Add similar buttons for other stats
                                      updatePlayerStatButton(context, 'keeper',
                                          keeper, trainingPoints),
                                      updatePlayerStatButton(context, 'defense',
                                          defense, trainingPoints),
                                      updatePlayerStatButton(
                                          context,
                                          'playmaking',
                                          playmaking,
                                          trainingPoints),
                                      updatePlayerStatButton(context, 'passes',
                                          passes, trainingPoints),
                                      updatePlayerStatButton(context, 'winger',
                                          winger, trainingPoints),
                                      updatePlayerStatButton(context, 'scoring',
                                          scoring, trainingPoints),
                                      updatePlayerStatButton(context,
                                          'freekick', freekick, trainingPoints),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Icon(
                      Icons.switch_access_shortcut_add,
                      size: iconSizeMedium,
                      color: Colors.green,
                    ),
                  )
                : Icon(
                    Icons.switch_access_shortcut_add,
                    size: iconSizeMedium,
                    color: Colors.red,
                  ),
          ),
          const SizedBox(height: 6.0),
          getStatLinearWidget('Stamina', stamina),
          const SizedBox(height: 6.0),
          getStatLinearWidget('Form', form),
          const SizedBox(height: 6.0),
          getStatLinearWidget('Experience', experience),
          SizedBox(
            width: double.infinity,
            height: 240, // Adjust the height as needed
            child: flutter_radar_chart.RadarChart.dark(
              ticks: const [25, 50, 75, 100],
              features: const [
                'GK',
                'DF',
                'PA',
                'PL',
                'WI',
                'SC',
                'FK',
              ],
              data: [features],
            ),
          ),
        ],
      ),
    );
  }

  Widget updatePlayerStatButton(
      BuildContext context, String stat, double value, double trainingPoints) {
    if (value >= 100) {
      return Row(
        children: [
          Icon(Icons.vertical_align_top, color: Colors.grey),
          Text('Stat ${stat} is already at maximum value!',
              style: TextStyle(color: Colors.red)),
        ],
      );
    }
    return TextButton(
      onPressed: () async {
        try {
          await supabase.from('players').update({
            stat: min(value + 1, 100),
            'training_points': trainingPoints - 1,
          }).match({'id': id});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Row(
              children: [
                Icon(Icons.celebration),
                Text('Successfully updated player ${stat} stat! Hooray!'),
              ],
            )),
          );
          Navigator.of(context).pop();
        } on PostgrestException catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'SUPABASE ERROR: When trying to update player ${stat} stat, got: ${error.message}'),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'UNKNOWN ERROR: When trying to update player ${stat} stat, got: $e')),
          );
        }
      },
      child: Row(
        children: [
          Text(
              '${stat} from ${value.toStringAsFixed(1)} to ${(value + 1).toStringAsFixed(1)}'),
        ],
      ),
      // child: Text('Increase ${stat}'),
    );
  }
}
