import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/widgets/creationDialogBox_Club.dart';
import 'package:opengoalz/extensionBuildContext.dart';

class UserPageAddClubTile extends StatelessWidget {
  final Profile user;

  const UserPageAddClubTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int clubCount = user.clubs.length;
    final bool canCreateClub =
        clubCount == 0 || user.creditsAvailable >= creditsRequiredForClub;
    final Color clubColor = canCreateClub ? Colors.green : Colors.orange;

    return ListTile(
      shape: shapePersoRoundedBorder(),
      leading: Icon(
        iconClub,
        color: Colors.green,
        size: iconSizeMedium,
      ),
      title: Row(
        children: [
          Text('Number of Clubs: '),
          Text(clubCount.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
      subtitle: Text(
          clubCount == 0
              ? 'First club is free, click the button to select one !'
              : canCreateClub
                  ? 'You can manage another club for ${creditsRequiredForClub} credits !'
                  : 'Missing ${creditsRequiredForClub - user.creditsAvailable} credits to manage another club',
          style: styleItalicBlueGrey),
      trailing: IconButton(
        icon: Icon(Icons.add_home_work, size: iconSizeMedium, color: clubColor),
        tooltip: 'Add Club',
        onPressed: () {
          if (canCreateClub) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CreationDialogBox_Club();
              },
            );
          } else {
            context.showSnackBarError(
              'You cannot manage an additional club, missing ${creditsRequiredForClub - user.creditsAvailable} credits',
              icon: Icon(
                Icons.warning,
                color: clubColor,
                size: iconSizeMedium,
              ),
            );
          }
        },
      ),
    );
  }
}
