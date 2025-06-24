import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/others/clubCardWidget.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/user_page/user_page_add_club_tile.dart';

class UserPageClubsTab extends StatelessWidget {
  final Profile user;

  const UserPageClubsTab({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Add club tile
        UserPageAddClubTile(user: user),

        /// List of clubs
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: user.clubs.length,
            itemBuilder: (context, index) {
              final Club club = user.clubs[index];
              return getClubCard(context, user, club, index);
            },
          ),
        ),
      ],
    );
  }
}
