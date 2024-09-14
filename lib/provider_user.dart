import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/handleFatalError.dart';
import 'package:rxdart/rxdart.dart';

class SessionProvider extends ChangeNotifier {
  Profile? user;

  /// Initialize the user
  void providerInitUser(Profile user) {
    this.user = user;
    notifyListeners();
  }

  /// Set the selected club of the user
  void providerSetSelectedClub(int idClub) {
    Club? selectedClub;
    print('Before Club Loop: user!.clubs');
    for (Club club in user!.clubs) {
      print('First Club Loop');
      if (club.id == idClub) {
        selectedClub = club;
        print('Selected Club Set: ${selectedClub.id}: ${selectedClub.name}');
        break;
      }
    }
    if (selectedClub == null) {
      throw Exception('Club not found');
    } else {
      user!.selectedClub = selectedClub;
    }
    notifyListeners();
  }

  /// Fetch the user from the database
  Future<void> providerFetchUser(BuildContext context,
      {String? userId, String? userName}) async {
    assert(userId != null || userName != null,
        'User ID or username must be provided');
    Completer<void> completer = Completer();

    String key = userId != null ? 'uuid_user' : 'username';
    String value = (userId ?? userName)!;

    try {
      await supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq(key, value)
          .map((maps) {
            print('Before User');
            // If the user is not found, throw an exception
            if (maps.isEmpty) {
              handleFatalError(context,
                  'User ${userName != null ? 'with username [$userName]' : 'with id [$userId]'} not found');
              throw Exception(
                  'User ${userName != null ? 'with username [$userName]' : 'with id [$userId]'} not found');
            }
            return maps
                .map((map) => Profile.fromMap(map,
                    connectedUserId: supabase.auth.currentUser!.id))
                .first;
          })
          .switchMap((Profile user) {
            print('Before Clubs');
            return supabase
                .from('clubs')
                .stream(primaryKey: ['id'])
                .eq('username', user.username)
                .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
                .map((List<Club> clubs) {
                  user.clubs = clubs;
                  // if (user.idDefaultClub != null) {
                  //   providerSetSelectedClub(user.idDefaultClub!);
                  // }
                  print('After Clubs');
                  return user;
                });
          })
          .switchMap((Profile user) {
            print('Before User2');
            return supabase
                .from('players')
                .stream(primaryKey: ['id'])
                .eq('username', user.username)
                .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
                .map((List<Player> players) {
                  user.players = players;
                  return user;
                });
          })
          .listen((Profile user) {
            providerInitUser(user);
            if (!completer.isCompleted) {
              completer.complete();
            }
          });
    } catch (error) {
      await handleFatalError(context, error.toString());
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    return completer.future;
  }
}
