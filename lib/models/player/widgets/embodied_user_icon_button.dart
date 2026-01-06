import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/user_page/user_page.dart';

/// Icon button that navigates to the user page of a player's embodied user
///
/// This widget displays a user icon with a tooltip showing the username
/// and navigates to the user's profile page when tapped.
class EmbodiedUserIconButton extends StatelessWidget {
  /// The username of the user who embodies the player
  final String userName;

  const EmbodiedUserIconButton({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Embodied by: $userName',
      icon: Icon(
        iconUser,
        size: iconSizeMedium,
        color: Colors.blue,
      ),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserPage(
              userName: userName,
            ),
          ),
        );
      },
    );
  }
}
