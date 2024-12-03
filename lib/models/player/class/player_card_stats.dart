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
            title: Text(
                'Points gained this season: ${trainingPointsUsed.floor()}'),
            subtitle: Text(
              'Gain training points thanks to the staff',
              style: styleItalicBlueGrey,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PlayerTrainingDialog(player: this);
                },
              );
            },
          ),
          getStatLinearWidget('Motivation', motivation, context),
          getStatLinearWidget('Form', form, context),
          getStatLinearWidget('Stamina', stamina, context),
          getStatLinearWidget('Experience', experience, context),
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
}
