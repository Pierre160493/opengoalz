import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/class/club_widgets.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'package:opengoalz/widgets/history_timeline_widget.dart';

class ClubHistoryPage extends StatefulWidget {
  final Club club;

  const ClubHistoryPage({Key? key, required this.club}) : super(key: key);

  @override
  _ClubHistoryPageState createState() => _ClubHistoryPageState();
}

class _ClubHistoryPageState extends State<ClubHistoryPage> {
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
        title: Row(
          children: [
            getClubName(context, widget.club),
            Text(' History'),
          ],
        ),
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
            return historyTimelineWidget(
                context, listClubDataHistory, null, null);
          }
        },
      ),
    );
  }
}
