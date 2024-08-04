import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/gameUser.dart';
import 'package:opengoalz/classes/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:rxdart/rxdart.dart';

class SessionProvider extends ChangeNotifier {
  GameUser? user;

  /// Initialize the user
  void providerInitUser(GameUser user) {
    this.user = user;
    notifyListeners();
  }

  /// Set the selected club of the user
  void providerSetSelectedClub(int idClub) {
    Club? selectedClub;
    for (Club club in user!.clubs) {
      if (club.id == idClub) {
        selectedClub = club;
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
  Future<void> providerFetchUser(
      {String? userId = null, String? userName = null}) {
    assert(userId != null || userName != null,
        'User ID or username must be provided');
    Completer<void> completer = Completer();

    String key = userId != null ? 'uuid_user' : 'username';
    String value = (userId ?? userName)!;

    supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq(key, value)
        .map((maps) => maps
            .map((map) => GameUser.fromMap(map,
                connectedUserId: supabase.auth.currentUser!.id))
            .first)
        .switchMap((GameUser user) {
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .eq('username', user.username)
              .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
              .map((List<Club> clubs) {
                user.clubs = clubs;
                if (user.idDefaultClub != null)
                  providerSetSelectedClub(user.idDefaultClub!);
                else {
                  user.selectedClub = user.clubs.first;
                }
                return user;
              });
        })
        .switchMap((GameUser user) {
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
        .listen((GameUser user) {
          providerInitUser(user);
          if (!completer.isCompleted) {
            completer.complete();
          }
        });

    return completer.future;
  }
}
