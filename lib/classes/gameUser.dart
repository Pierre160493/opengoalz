import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/user_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

class GameUser {
  bool isConnectedUser = false; // True if the profile is the connected user
  late Club selectedClub; // Selected club of the profile
  List<Club> clubs = []; // List of clubs belonging to the profile
  int? idDefaultClub; // ID of the default club
  List<Player> players = []; // List of players belonging to the profile

  GameUser({
    required this.id,
    required this.username,
    required this.createdAt,
    this.idDefaultClub,
  });

  /// User ID of the profile
  final String id;

  /// Username of the profile
  final String username;

  /// Date and time when the profile was created
  final DateTime createdAt;

  GameUser.fromMap(Map<String, dynamic> map, {String? connectedUserId})
      : id = map['uuid_user'],
        isConnectedUser =
            connectedUserId != null && map['uuid_user'] == connectedUserId,
        username = map['username'],
        createdAt = DateTime.parse(map['created_at']),
        idDefaultClub = map['id_default_club'];

  Widget getUserName() {
    return Row(
      children: [
        Icon(iconUser),
        SizedBox(width: 3),
        Text(username),
        Icon(isConnectedUser ? Icons.check_circle : Icons.portable_wifi_off,
            color: isConnectedUser ? Colors.green : Colors.red),
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
        child: getUserName());
  }
}

Widget getUserName(BuildContext context, String? userName) {
  if (userName == null) {
    return Row(
      children: [
        Icon(iconBot),
        SizedBox(width: 3),
        Text(' No User'),
      ],
    );
  }

  return Row(
    children: [
      Icon(iconUser),
      SizedBox(width: 3),
      Text(userName),
      if (userName ==
          Provider.of<SessionProvider>(context)
              .user
              ?.username) // If the user is the connected user
        Icon(Icons.check_circle, color: Colors.green),
    ],
  );
}

Widget getUserNameClickable(BuildContext context, String? userName) {
  if (userName == null) {
    return getUserName(context, userName);
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
      child: getUserName(context, userName));
}

// Widget getUserNameClickable2(BuildContext context, String? userName) {
//   if (userName == null) {
//     return Row(
//       children: [
//         Icon(iconUser),
//         Text(' No User'),
//       ],
//     );
//   }

//   return StreamBuilder<GameUser>(
//     stream: supabase
//         .from('profiles')
//         .stream(primaryKey: ['id'])
//         .eq('username', userName)
//         .map((maps) => maps.map((map) => GameUser.fromMap(map)).first),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return CircularProgressIndicator();
//       } else if (snapshot.hasError) {
//         return Text('ERROR: ${snapshot.error}');
//       } else {
//         final user = snapshot.data!;
//         return user.getUserNameClickable(context);
//       }
//     },
//   );
// }
