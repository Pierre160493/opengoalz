import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

Widget getUserNameWidget(String? idUser) {
  if (idUser == null) {
    return Text('ERROR: User id is null !');
  }

  return StreamBuilder<Map>(
    stream: supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('uuid_user', idUser)
        .map((maps) => maps
            .map((map) => {
                  'created_at': map['created_at'],
                  'username': map['username'],
                })
            .first),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Placeholder row while loading
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('ERROR: ${snapshot.error}');
      } else {
        final profile = snapshot.data!;
        if (profile.isEmpty) {
          return Text('ERROR: Profile with id ${idUser} not found');
        }
        // Actual row with data
        return Text(
          profile['username'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      }
    },
  );
}

Widget getUserNameWidgetClickable(BuildContext context, String? idUser) {
  return InkWell(
    onTap: () {
      // Navigator.push(
      //   context,
      //   UserPage.route(idUser),
      // );
    },
    child: Row(
      children: [
        getUserNameWidget(idUser),
      ],
    ),
  );
}
