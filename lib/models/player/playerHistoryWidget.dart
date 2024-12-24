import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/AgeAndBirth.dart';
import 'package:opengoalz/models/club/clubNameListTile.dart';
import 'package:opengoalz/models/player/class/player.dart';

class PlayerCardHistoryWidget extends StatefulWidget {
  final Player player;

  const PlayerCardHistoryWidget({Key? key, required this.player})
      : super(key: key);

  @override
  _PlayerCardHistoryWidgetState createState() =>
      _PlayerCardHistoryWidgetState();
}

class _PlayerCardHistoryWidgetState extends State<PlayerCardHistoryWidget> {
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

  TextSpan _parseDescription(String description) {
    final RegExp regex = RegExp(r'\{(.+?)\}');
    final List<TextSpan> spans = [];
    int start = 0;

    for (final match in regex.allMatches(description)) {
      if (match.start > start) {
        spans.add(TextSpan(text: description.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ));
      start = match.end;
    }

    if (start < description.length) {
      spans.add(TextSpan(text: description.substring(start)));
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map>>(
      stream: _playerHistoryStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          List<Map> listPlayerHistory = snapshot.data!;
          return Expanded(
            child: ListView.builder(
              itemCount: listPlayerHistory.length,
              itemBuilder: (context, index) {
                final history = listPlayerHistory[index];
                return ListTile(
                  leading: Icon(iconHistory,
                      color: Colors.green, size: iconSizeMedium),
                  title: RichText(
                    text: _parseDescription(
                        history['description'] ?? 'No description'),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            iconCalendar,
                            color: Colors.blueGrey,
                            size: iconSizeSmall,
                          ),
                          Text(
                            'Date: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(history['created_at']))}',
                            style: styleItalicBlueGrey,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            iconAge,
                            color: Colors.blueGrey,
                            size: iconSizeSmall,
                          ),
                          Text(
                            getAgeString(calculateAge(widget.player.dateBirth,
                                widget.player.multiverseSpeed,
                                date: DateTime.parse(history['created_at']))),
                            style: styleItalicBlueGrey,
                          ),
                        ],
                      ),
                    ],
                  ),
                  shape: shapePersoRoundedBorder(),
                );
              },
            ),
          );
        }
      },
    );
  }
}
