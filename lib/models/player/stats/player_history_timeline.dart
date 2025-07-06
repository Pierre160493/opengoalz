import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/widgets/historyTimelineWidget.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';

class PlayerHistoryTimeline extends StatefulWidget {
  final Player player;

  const PlayerHistoryTimeline({Key? key, required this.player})
      : super(key: key);

  @override
  _PlayerHistoryTimelineState createState() => _PlayerHistoryTimelineState();
}

class _PlayerHistoryTimelineState extends State<PlayerHistoryTimeline> {
  late Stream<List<Map>> _playerHistoryStream;

  @override
  void initState() {
    super.initState();

    _playerHistoryStream = supabase
        .from('players_history')
        .stream(primaryKey: ['id'])
        .eq('id_player', widget.player.id)
        .order('created_at');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map>>(
      stream: _playerHistoryStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingCircularAndText('Loading player history');
        } else if (snapshot.hasError) {
          return ErrorWithBackButton(errorMessage: snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return ErrorWithBackButton(errorMessage: 'No data available');
        } else {
          List<Map> listPlayerHistory = snapshot.data!;
          return historyTimelineWidget(
            context,
            listPlayerHistory,
            widget.player.dateBirth,
            widget.player.multiverseSpeed,
          );
          // return SingleChildScrollView(
          //   child: Column(
          //     children: [
          //       ListTile(
          //         leading: Icon(
          //           Icons.history,
          //           size: iconSizeLarge,
          //           color: Colors.green,
          //         ),
          //         title: Row(
          //           children: [
          //             Text(
          //               'History of ',
          //             ),
          //             Text(widget.player.getFullName(),
          //                 style: TextStyle(fontWeight: FontWeight.bold)),
          //           ],
          //         ),
          //         subtitle: Text(
          //           'This page shows the history of the player.',
          //           style: TextStyle(
          //             fontStyle: FontStyle.italic,
          //             color: Colors.blueGrey,
          //           ),
          //         ),
          //         shape: shapePersoRoundedBorder(Colors.green, 3),
          //       ),
          //       ListView.builder(
          //         shrinkWrap: true,
          //         physics: NeverScrollableScrollPhysics(),
          //         itemCount: listPlayerHistory.length,
          //         itemBuilder: (context, index) {
          //           final history = listPlayerHistory[index];
          //           return ListTile(
          //             leading: Icon(iconHistory,
          //                 color: Colors.green, size: iconSizeMedium),
          //             title: RichText(
          //               text: stringParser(context,
          //                   history['description'] ?? 'No description'),
          //             ),
          //             subtitle: Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: [
          //                 Row(
          //                   children: [
          //                     Icon(
          //                       iconCalendar,
          //                       color: Colors.green,
          //                       size: iconSizeSmall,
          //                     ),
          //                     Text(
          //                       DateFormat(persoDateFormat).format(
          //                           DateTime.parse(history['created_at'])),
          //                       style: styleItalicBlueGrey,
          //                     ),
          //                   ],
          //                 ),
          //                 Row(
          //                   children: [
          //                     Icon(
          //                       iconAge,
          //                       color: Colors.green,
          //                       size: iconSizeSmall,
          //                     ),
          //                     Text(
          //                       getAgeString(calculateAge(
          //                           widget.player.dateBirth,
          //                           widget.player.multiverseSpeed,
          //                           dateEnd:
          //                               DateTime.parse(history['created_at']))),
          //                       style: styleItalicBlueGrey,
          //                     ),
          //                   ],
          //                 ),
          //               ],
          //             ),
          //             shape: shapePersoRoundedBorder(),
          //           );
          //         },
          //       ),
          //     ],
          //   ),
          // );
        }
      },
    );
  }
}
