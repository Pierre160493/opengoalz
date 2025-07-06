import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/widgets/graphWidget.dart';

Widget getPlayerHistoryGraph(
    BuildContext context, int id, List<String> fieldsToPlot, String title) {
  return FutureBuilder<List<Map>>(
    future: supabase
        .from('players_history_stats')
        .select('created_at, ${fieldsToPlot.join(", ")}')
        .eq('id_player', id)
        .order('created_at', ascending: true)
        .then((response) => response),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return loadingCircularAndText('Loading player history...');
      } else if (snapshot.hasError) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
            'Failed to load player history: ${snapshot.error}',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
            'No data available for player history.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      }

      final historyData = snapshot.data!;

      // Check for null values in the required fields
      for (var field in fieldsToPlot) {
        if (historyData.any((item) => item[field] == null)) {
          return AlertDialog(
            title: Text('Data Error'),
            content: Text(
              'Error: Missing data for field "$field".',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
        title: title,
        yValues: fieldsToPlot.map((field) {
          return historyData
              .map((item) => (item[field] as num).toDouble())
              .toList();
        }).toList(),
        typeXAxis: XAxisType.weekHistory,
      );

      return ChartDialogBox(chartData: chartData);
    },
  );
}
