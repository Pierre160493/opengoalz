import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/mail.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/user_page.dart';
import 'package:opengoalz/provider_theme_app.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/sendMail.dart';
import 'package:provider/provider.dart';

class Profile {
  bool isConnectedUser = false; // True if the profile is the connected user
  Club? selectedClub; // Selected club of the profile
  List<Club> clubs = []; // List of clubs belonging to the profile
  List<Player> players = []; // List of players belonging to the profile
  List<Mail> mails = []; // List of mails belonging to the profile

  Profile({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.idDefaultClub,
    required this.lastUsernameUpdate,
    required this.numberClubsAvailable,
    required this.numberPlayersAvailable,
  });

  final String id; // User ID of the profile stored in the auth.users table
  final String username;
  final DateTime createdAt;
  final DateTime? lastUsernameUpdate;
  final int? idDefaultClub;
  final int numberClubsAvailable;
  final int numberPlayersAvailable;

  Profile.fromMap(Map<String, dynamic> map, {String? connectedUserId})
      : id = map['uuid_user'],
        isConnectedUser =
            connectedUserId != null && map['uuid_user'] == connectedUserId,
        username = map['username'],
        createdAt = DateTime.parse(map['created_at']).toLocal(),
        idDefaultClub = map['id_default_club'],
        lastUsernameUpdate = map['last_username_update'] != null
            ? DateTime.parse(map['last_username_update']).toLocal()
            : null,
        numberClubsAvailable = map['number_clubs_available'] ?? 1,
        numberPlayersAvailable = map['number_players_available'] ?? 1;

  Map<String, dynamic> toMap() {
    return {
      'uuid_user': id,
      'username': username,
      'created_at': createdAt.toIso8601String(),
      'id_default_club': idDefaultClub,
      'last_username_update': lastUsernameUpdate?.toIso8601String(),
      'number_clubs_available': numberClubsAvailable,
      'number_players_available': numberPlayersAvailable,
    };
  }

  Widget getUserName(BuildContext context) {
    return Row(
      children: [
        Icon(iconUser, color: isConnectedUser ? colorIsSelected : Colors.blue),
        formSpacer3,
        Text(username),
        formSpacer3,
        // if (isConnectedUser)
        // Icon(isConnectedUser ? Icons.check_circle : Icons.portable_wifi_off,
        //     color: isConnectedUser ? Colors.green : Colors.red),
        if (!isConnectedUser)
          Tooltip(
            message: 'Send Mail',
            child: IconButton(
              onPressed: () async {
                sendMailDialog(context,
                    username: username, idClub: selectedClub!.id);
              },
              icon: Icon(Icons.quick_contacts_mail, size: iconSizeSmall),
            ),
          ),
      ],
    );
  }

  Widget getUserNameClickable(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserPage(
                userName: username,
              ),
            ),
          );
        },
        child: getUserName(context));
  }

  Widget returnToConnectedUserIconButton(BuildContext context) {
    return Tooltip(
      message: 'Return to your profile',
      child: IconButton(
        onPressed: () async {
          bool switchConfirmed = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Confirm Switch Profiles"),
                content: Text("Return to your profile ?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      // Dismiss the dialog and return false to indicate cancellation
                      Navigator.of(context).pop(false);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      // Dismiss the dialog and return true to indicate confirmation
                      Navigator.of(context).pop(true);
                    },
                    child: Text("Switch"),
                  ),
                ],
              );
            },
          );

          // If switch is confirmed, proceed with switching
          if (switchConfirmed == true) {
            await Provider.of<SessionProvider>(context, listen: false)
                .providerFetchUser(context,
                    userId: supabase.auth.currentUser!.id);

            /// Modify the app theme if the user is not the connected user
            Provider.of<ThemeProvider>(context, listen: false)
                .setOtherThemeWhenSelectedUserIsNotConnectedUser(
                    Provider.of<SessionProvider>(context, listen: false)
                            .user
                            ?.isConnectedUser ??
                        false);

            /// Launch UserPage Page
            Navigator.of(context)
                .pushAndRemoveUntil(UserPage.route(), (route) => false);
          }
        },
        icon: Icon(Icons.keyboard_return, size: iconSizeSmall),
      ),
    );
  }
}

Widget getUserName(BuildContext context, {String? userName, int? idClub}) {
  if (userName == null) {
    return Row(
      children: [
        Icon(iconBot, color: Colors.red),
        formSpacer3,
        Text(' No User'),
      ],
    );
  }

  bool isSelected = userName ==
      Provider.of<SessionProvider>(context, listen: false).user?.username;

  return Row(
    children: [
      Icon(iconUser, color: isSelected ? colorIsSelected : Colors.blue),
      formSpacer3,
      Text(userName),
      if (isSelected) // If the user is the connected user
        Icon(Icons.check_circle, color: Colors.green),
      if (!isSelected) // If the user is not the connected user
        Tooltip(
          message: 'Send Mail',
          child: IconButton(
            onPressed: () async {
              // showSendMailDialog(context, user.selectedClub.id);
              sendMailDialog(context, idClub: idClub, username: userName);
            },
            icon: Icon(Icons.quick_contacts_mail, size: iconSizeSmall),
          ),
        ),
    ],
  );
}

Widget getUserNameClickable(BuildContext context, {String? userName}) {
  if (userName == null) {
    return getUserName(context, userName: userName);
  }

  return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserPage(
              userName: userName,
            ),
          ),
        );
      },
      child: getUserName(context, userName: userName));
}
