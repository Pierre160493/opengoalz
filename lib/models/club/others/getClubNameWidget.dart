import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/errorTextWidget.dart';
import 'package:provider/provider.dart';

/// Widget that displays a clickable club name
///
/// Handles three scenarios:
/// 1. Club object provided - uses club's built-in clickable widget
/// 2. Club ID provided - fetches club data via StreamBuilder
/// 3. No club/invalid ID - shows "No Club" placeholder
class ClubNameClickable extends StatelessWidget {
  /// The club object (preferred when available)
  final Club? club;

  /// The club ID to fetch data for (used when club object is null)
  final int? idClub;

  const ClubNameClickable({
    Key? key,
    this.club,
    this.idClub,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Case 1: Club object provided - use it directly
    if (club != null) {
      return club!.getClubNameClickable(context);
    }

    // Case 2: Club ID provided - fetch club data
    if (idClub != null) {
      // Special case: ID 0 means no club
      if (idClub == 0) {
        return _buildNoClubWidget();
      }

      return _buildStreamBuilderWidget(context);
    }

    // Case 3: Neither club nor ID provided
    return _buildNoClubWidget();
  }

  /// Builds the "No Club" placeholder widget
  Widget _buildNoClubWidget() {
    return Row(
      children: [
        Icon(iconClub),
        Text(' No Club'),
      ],
    );
  }

  /// Builds the StreamBuilder widget for fetching club data
  Widget _buildStreamBuilderWidget(BuildContext context) {
    return StreamBuilder<Club>(
      stream: supabase
          .from('clubs')
          .stream(primaryKey: ['id'])
          .eq('id', idClub!)
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
          final Club fetchedClub = snapshot.data!;
          return fetchedClub.getClubNameClickable(context);
        }

        // Fallback case
        return _buildNoClubWidget();
      },
    );
  }
}

/// Legacy function wrapper for backward compatibility
///
/// **Deprecated**: Use ClubNameClickable widget instead
@Deprecated('Use ClubNameClickable widget instead')
Widget getClubNameClickable(BuildContext context, Club? club, int? idClub) {
  return ClubNameClickable(
    club: club,
    idClub: idClub,
  );
}
