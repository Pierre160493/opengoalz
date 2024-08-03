import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:opengoalz/constants.dart';

class GameUser {
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

  GameUser.fromMap(Map<String, dynamic> map)
      : id = map['uuid_user'],
        username = map['username'],
        createdAt = DateTime.parse(map['created_at']),
        idDefaultClub = map['id_default_club'];

  Widget getUserName() {
    return Row(
      children: [
        Icon(iconUser),
        Text(username),
      ],
    );
  }

  Widget getUserNameClickable(BuildContext context) {
    return InkWell(
        // onTap: () {
        //   Navigator.pushNamed(context, '/profile', arguments: this);
        // },
        child: getUserName());
  }
}

Widget getUserNameClickable(BuildContext context, String? userName) {
  if (userName == null) {
    return Row(
      children: [
        Icon(iconUser),
        Text(' No User'),
      ],
    );
  }

  return StreamBuilder<GameUser>(
    stream: supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('username', userName)
        .map((maps) => maps.map((map) => GameUser.fromMap(map)).first),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('ERROR: ${snapshot.error}');
      } else {
        final user = snapshot.data!;
        return user.getUserNameClickable(context);
      }
    },
  );
}
