import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/gameUser.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class SessionProvider extends ChangeNotifier {
  GameUser? user;

  void providerSetUser(GameUser user) {
    this.user = user;
    notifyListeners();
  }

  Future<void> providerFetchUser(String userId) {
    Completer<void> completer = Completer();

    supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('uuid_user', userId)
        .map((maps) => maps.map((map) => GameUser.fromMap(map)).first)
        .switchMap((GameUser user) {
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('username', user.username)
              .map((maps) => maps.map((map) => Club.fromMap(map: map)).toList())
              .map((List<Club> clubs) {
                user.clubs = clubs;
                return user;
              });
        })
        .listen((GameUser user) {
          providerSetUser(user);
          if (!completer.isCompleted) {
            completer.complete();
          }
        });

    return completer.future;
  }
}













// class SessionProvider_old extends ChangeNotifier {
//   late StreamController<GameUser> userStreamController;
//   GameUser? user;

//   SessionProvider() {
//     print('testPierre: Debut SessionProvider');
//     userStreamController = StreamController<GameUser>.broadcast();
//   }

//   Stream<GameUser> get userStream => userStreamController.stream;

//   void setGameUser(GameUser user) {
//     print('testPierre: Debut setGameUser dans SessionProvider');
//     user = user;
//     notifyListeners();
//   }

//   void updateUserStream(String userId) {
//     print(
//         'testPierre: Debut updateUserStream dans SessionProvider: userId: $userId');
//     supabase
//         .from('profiles')
//         .stream(primaryKey: ['id'])
//         .eq('uuid_user', userId)
//         .map((maps) => maps.map((map) => GameUser.fromMap(map)).first)
//         .switchMap((GameUser user) {
//           print('testPierre: Debut switchMap dans updateUserStream');
//           return supabase
//               .from('clubs')
//               .stream(primaryKey: ['id'])
//               .eq('username', user.username)
//               .map((maps) => maps.map((map) => Club.fromMap(map: map)).toList())
//               .map((List<Club> clubs) {
//                 print(
//                     'testPierre: Debut map dans updateUserStream => clubs.length: ${clubs.length}');
//                 user.clubs = clubs;
//                 return user;
//               });
//         })
//         .listen((user) {
//           userStreamController.add(user);
//           print('User: ${user.username}');
//           for (Club club in user.clubs) {
//             print('Club: ${club.nameClub}');
//           }
//         });

//     notifyListeners();
//     print('testPierre: FIN updateUserStream dans SessionProvider');
//   }

//   @override
//   void dispose() {
//     userStreamController.close();
//     super.dispose();
//   }
// }

/// Ne sert potentiellement plus à rien (A SUPPRIMER A LA FIN SI TOUT EST OK)
// void navigateToHomePage(BuildContext context) {
//   final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
//   sessionProvider.updateUserStream(
//       supabase.auth.currentUser!.id); // Update the club stream

//   print(
//       'testPierre: Debut navigateToHomePage dans SessionProvider mais dehors');
//   sessionProvider.userStream.listen((GameUser user) {
//     for (Club club in user.clubs) {
//       if (club.id == user.idDefaultClub) {
//         user.selectedClub = club;
//       }
//     }
//     sessionProvider.setGameUser(user);
//   });

//   print('testPierre: Fin navigateToHomePage GOTO HomePage');
//   Navigator.of(context).pushAndRemoveUntil(HomePage.route(), (route) => false);
// }
