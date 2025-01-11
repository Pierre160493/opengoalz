import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/mail.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/handleFatalError.dart';
import 'package:rxdart/rxdart.dart';

class SessionProvider extends ChangeNotifier {
  Profile? user;
  bool _isFirstRun = true; // Flag to track the first run

  /// Initialize the user
  void providerInitUser(Profile userInput) {
    user = userInput;
    if (user!.idDefaultClub != null) {
      providerSetSelectedClub(user!.idDefaultClub!);
    }
    notifyListeners();
  }

  /// Set the selected club of the user
  void providerSetSelectedClub(int idClub) {
    Club? selectedClub;
    for (Club club in user!.clubs) {
      if (club.id == idClub) {
        selectedClub = club;
        print('Selected club: ${selectedClub.name}');
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
            return supabase
                .from('clubs')
                .stream(primaryKey: ['id'])
                .eq('username', user.username)
                .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
                .map((List<Club> clubs) {
                  user.clubs = clubs;

                  print('After Clubs');
                  return user;
                });
          })
          .switchMap((Profile user) {
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

          /// Fetch the mails of the user
          .switchMap((Profile profile) {
            return supabase
                .from('messages_mail')
                .stream(primaryKey: ['id'])
                .eq('username_to', profile.username)
                .order('created_at', ascending: false)
                .map((maps) => maps.map((map) => Mail.fromMap(map)).toList())
                .map((List<Mail> mails) {
                  profile.mails = mails;
                  print('User mails: ${profile.mails.length}');
                  return profile;
                });
          })

          /// Fetch the mails of the clubs of the user
          .switchMap((Profile profile) {
            if (profile.clubs.isEmpty) {
              return Stream.value(profile);
            }
            return supabase
                .from('messages_mail')
                .stream(primaryKey: ['id'])
                .inFilter(
                    'id_club_to', profile.clubs.map((club) => club.id).toList())
                .order('created_at', ascending: false)
                .map((maps) => maps.map((map) => Mail.fromMap(map)).toList())
                .map((List<Mail> mails) {
                  for (Club club in profile.clubs) {
                    club.mails = mails
                        .where((mail) => mail.idClubTo == club.id)
                        .toList();
                    print('Club mails: ${club.mails.length}');
                  }
                  return profile;
                });
          })
          .listen((Profile user) {
            print('### Received new data from session provider stream');
            if (_isFirstRun) {
              providerInitUser(user);
              _isFirstRun = false; // Set the flag to false after the first run
            }
            notifyListeners(); // Ensure listeners are notified
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
