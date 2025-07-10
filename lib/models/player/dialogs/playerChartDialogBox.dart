import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/widgets/graph_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> showHistoryChartDialog(
    BuildContext context, int idToFetch, String columnName, String titleName,
    {var dataToAppend = null}) async {
  final List<num>? dataHistory =
      await fetchDataHistory(context, idToFetch, columnName);

  if (dataHistory != null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final chartData = ChartData(
          title: titleName,
          yValues: [
            if (dataToAppend != null)
              [...dataHistory, dataToAppend]
            else
              dataHistory
          ],
          typeXAxis: XAxisType.weekHistory,
        );

        return ChartDialogBox(chartData: chartData);
      },
    );
  }
}

// Method to fetch club data history from Supabase
Future<List<num>?> fetchDataHistory(
    BuildContext context, int idToFetch, String dataToFetch) async {
  try {
    final response = await supabase
        .from('players_history_stats')
        .select(dataToFetch)
        .eq('id_player', idToFetch)
        // .order('season_number', ascending: true)
        // .order('week_number', ascending: true);
        .order('created_at', ascending: true);
    print('response: $response');
    final List<num> values = (response as List<dynamic>)
        .map((item) => (item[dataToFetch] as num))
        .toList();
    return values;
  } on PostgrestException catch (error) {
    context.showSnackBarPostgreSQLError('PostgreSQL ERROR: ${error.message}');
  } catch (error) {
    context.showSnackBarError('Unknown ERROR: $error');
  }
  return null;
}
