import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/functions/stringParser.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';

class ClubCardHistoryWidget extends StatefulWidget {
  final Club club;

  const ClubCardHistoryWidget({Key? key, required this.club}) : super(key: key);

  @override
  _ClubCardHistoryWidgetState createState() => _ClubCardHistoryWidgetState();
}

class _ClubCardHistoryWidgetState extends State<ClubCardHistoryWidget> {
  late Stream<List<Map>> _ClubDataHistoryStream;

  @override
  void initState() {
    super.initState();

    _ClubDataHistoryStream = supabase
        .from('clubs_history')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.club.id)
        .order('created_at');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club History'),
      ),
      body: StreamBuilder<List<Map>>(
        stream: _ClubDataHistoryStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCircularAndText('Loading club history...');
          } else if (snapshot.hasError) {
            return ErrorWithBackButton(errorMessage: snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return ErrorWithBackButton(errorMessage: 'No data available');
          } else {
            List<Map> listClubDataHistory = snapshot.data!;
            return ListView.builder(
              itemCount: listClubDataHistory.length,
              itemBuilder: (context, index) {
                final history = listClubDataHistory[index];
                return ListTile(
                  leading: Icon(iconHistory,
                      color: Colors.green, size: iconSizeMedium),
                  title: RichText(
                    text: stringParser(
                        context, history['description'] ?? 'No description'),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(
                        iconCalendar,
                        color: Colors.blueGrey,
                        size: iconSizeSmall,
                      ),
                      Text(
                        DateFormat(persoDateFormat)
                            .format(DateTime.parse(history['created_at'])),
                        style: styleItalicBlueGrey,
                      ),
                    ],
                  ),
                  shape: shapePersoRoundedBorder(),
                );
              },
            );
          }
        },
      ),
    );
  }
}
