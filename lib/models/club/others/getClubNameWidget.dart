import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club_widgets.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/error_text_widget.dart';
import 'package:provider/provider.dart';

/// Widget that displays a clickable club name from its ID
///
/// Fetches club data via StreamBuilder or shows "No Club" placeholder if ID is 0
class ClubNameClickable extends StatelessWidget {
  /// The club ID to fetch data for
  final int idClub;

  const ClubNameClickable({
    Key? key,
    required this.idClub,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Special case: ID 0 means no club
    if (idClub == 0) {
      return _buildNoClubWidget();
    }

    return _buildStreamBuilderWidget(context);
  }

  /// Builds the "No Club" placeholder widget
  Widget _buildNoClubWidget() {
    return Row(
      children: [
        Icon(iconClub, size: iconSizeSmall, color: Colors.orange),
        Text(' No Club',
            style: TextStyle(fontSize: fontSizeMedium, color: Colors.orange)),
      ],
    );
  }

  /// Builds the StreamBuilder widget for fetching club data
  Widget _buildStreamBuilderWidget(BuildContext context) {
    return StreamBuilder<Club>(
      stream: supabase
          .from('clubs')
          .stream(primaryKey: ['id'])
          .eq('id', idClub)
          .map((maps) => maps
              .map((map) => Club.fromMap(
                  map,
                  Provider.of<UserSessionProvider>(context, listen: false)
                      .user))
              .first),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
            child: LinearProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return ErrorTextWidget(snapshot.error.toString());
        }

        if (snapshot.hasData) {
          return getClubNameClickable(context, snapshot.data!);
        }

        // Fallback case
        return _buildNoClubWidget();
      },
    );
  }
}
