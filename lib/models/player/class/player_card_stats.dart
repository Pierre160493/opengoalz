part of 'player.dart';

extension PlayerCardStats on Player {
  Widget playerCardStatsWidget(BuildContext context) {
    final features = [
      keeper,
      defense,
      passes,
      playmaking,
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
            title: Text('Training points: ${trainingPoints.floor()}'),
            subtitle: Text(
              'Gain training points thanks to the staff',
              style: styleItalicBlueGrey,
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
                                title: ListTile(
                                  leading: Icon(
                                    Icons.query_stats,
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                      'Which stat do you wish to increase ?'),
                                  subtitle: Text(
                                      'You have ${trainingPoints.floor()} training points'),
                                ),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      for (var entry in {
                                        'keeper': keeper,
                                        'defense': defense,
                                        'playmaking': playmaking,
                                        'passes': passes,
                                        'winger': winger,
                                        'scoring': scoring,
                                        'freekick': freekick,
                                      }.entries)
                                        ListTile(
                                          leading: Icon(Icons.query_stats),
                                          title: Text(
                                              '${entry.key[0].toUpperCase()}${entry.key.substring(1)}'),
                                          subtitle: Text(
                                              'Current value: ${entry.value.toStringAsFixed(1)}',
                                              style: styleItalicBlueGrey),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                    Icons.exposure_plus_1,
                                                    color: Colors.green),
                                                onPressed: () => updateStat(
                                                    context,
                                                    entry.key,
                                                    entry.value,
                                                    1),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.filter_5,
                                                    color: Colors.green),
                                                onPressed: () => updateStat(
                                                    context,
                                                    entry.key,
                                                    entry.value,
                                                    5),
                                              ),
                                              // IconButton(
                                              //   icon: Icon(
                                              //       Icons.exposure_plus_10,
                                              //       color: Colors.green),
                                              //   onPressed: () => updateStat(
                                              //       context,
                                              //       entry.key,
                                              //       entry.value,
                                              //       10),
                                              // ),
                                              // IconButton(
                                              //   icon: Icon(Icons.exposure,
                                              //       color: Colors.green),
                                              //   onPressed: () => updateStat(
                                              //       context,
                                              //       entry.key,
                                              //       entry.value,
                                              //       100 - entry.value),
                                              // ),
                                            ],
                                          ),
                                        ),
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

  void updateStat(BuildContext context, String stat, double currentValue,
      double increment) async {
    if (currentValue < 100) {
      double newValue = min(currentValue + increment, 100);
      bool isOK = await operationInDB(
        context,
        'UPDATE',
        'players',
        data: {
          stat: newValue,
          'training_points': max(0, trainingPoints - increment),
        },
        matchCriteria: {'id': id},
      );
      if (isOK) {
        context.showSnackBarSuccess(
            'Successfully updated player $stat stat! Hooray!');
        Navigator.of(context).pop();
      }
    } else {
      context.showSnackBarError('Stat $stat is already at maximum value!');
    }
  }
}
