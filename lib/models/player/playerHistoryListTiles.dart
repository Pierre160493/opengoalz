import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/AgeAndBirth.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/functions/descriptionParser.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';

class PlayerHistoryListTiles extends StatefulWidget {
  final Player player;

  const PlayerHistoryListTiles({Key? key, required this.player})
      : super(key: key);

  @override
  _PlayerHistoryListTilesState createState() => _PlayerHistoryListTilesState();
}

class _PlayerHistoryListTilesState extends State<PlayerHistoryListTiles> {
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          List<Map> listPlayerHistory = snapshot.data!;
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.history,
                  size: iconSizeLarge,
                  color: Colors.green,
                ),
                title: Row(
                  children: [
                    Text(
                      'History of ',
                    ),
                    Text(widget.player.getFullName(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                subtitle: Text(
                  'This page shows the history of the player.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.blueGrey,
                  ),
                ),
                shape: shapePersoRoundedBorder(Colors.green, 3),
              ),
              SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: listPlayerHistory.length,
                  itemBuilder: (context, index) {
                    final history = listPlayerHistory[index];
                    return ListTile(
                      leading: Icon(iconHistory,
                          color: Colors.green, size: iconSizeMedium),
                      title: RichText(
                        text: parseDescriptionTextSpan(context,
                            history['description'] ?? 'No description'),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                iconCalendar,
                                color: Colors.green,
                                size: iconSizeSmall,
                              ),
                              Text(
                                DateFormat(persoDateFormat).format(
                                    DateTime.parse(history['created_at'])),
                                style: styleItalicBlueGrey,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                iconAge,
                                color: Colors.green,
                                size: iconSizeSmall,
                              ),
                              Text(
                                getAgeString(calculateAge(
                                    widget.player.dateBirth,
                                    widget.player.multiverseSpeed,
                                    date:
                                        DateTime.parse(history['created_at']))),
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
              ),
            ],
          );
        }
      },
    );
  }
}
