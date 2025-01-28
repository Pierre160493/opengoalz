import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/mail.dart';
import 'package:opengoalz/models/playerFavorite/player_favorite.dart';
import 'package:opengoalz/models/playerPoaching/player_poaching.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/handleFatalError.dart';
import 'package:rxdart/rxdart.dart';

class SessionProvider extends ChangeNotifier {
  Profile? user;

  /// Initialize the user
  // void providerInitUser(Profile userInput) {
  //   user = userInput;
  //   if (user!.idDefaultClub != null) {
  //     providerSetSelectedClub(user!.idDefaultClub!);
  //   }
  //   notifyListeners();
  // }

  // /// Set the selected club of the user
  // void providerSetSelectedClub(int idClub) {
  //   Club? selectedClub;
  //   for (Club club in user!.clubs) {
  //     if (club.id == idClub) {
  //       selectedClub = club;
  //       print('Selected club: ${selectedClub.name}');
  //       break;
  //     }
  //   }
  //   if (selectedClub == null) {
  //     throw Exception('Club not found');
  //   } else {
  //     user!.selectedClub = selectedClub;
  //   }
  //   notifyListeners();
  // }

  /// Fetch the user from the database
  Future<void> providerFetchUser(BuildContext context,
      {String? userId, String? userName, int? selectedIdClub}) async {
    assert(userId != null || userName != null,
        'User ID or username must be provided');
    Completer<void> completer = Completer();

    String key = userId != null ? 'uuid_user' : 'username';
    String value = (userId ?? userName)!;

    try {
      /// Fetch the user from the database
      await supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq(key, value)
          .map((maps) {
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

          /// Fetch the mails of the user
          .switchMap((Profile profile) {
            return supabase
                .from('mails')
                .stream(primaryKey: ['id'])
                .eq('username_to', profile.username)
                .order('created_at', ascending: false)
                .map((maps) => maps.map((map) => Mail.fromMap(map)).toList())
                .map((List<Mail> mails) {
                  profile.mails = mails;
                  return profile;
                });
          })

          /// Incarnated players of the user
          .switchMap((Profile user) {
            return supabase
                .from('players')
                .stream(primaryKey: ['id'])
                .eq('username', user.username)
                .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
                .map((List<Player> players) {
                  user.playersIncarnated = players;
                  return user;
                });
          })

          /// Fetch the clubs of the user
          .switchMap((Profile user) {
            return supabase
                .from('clubs')
                .stream(primaryKey: ['id'])
                .eq('username', user.username)
                .order('user_since', ascending: true)
                .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
                .map((List<Club> clubs) {
                  user.clubs = clubs;

                  /// Set the selected club of the user
                  if (selectedIdClub == null) {
                    selectedIdClub = user.idDefaultClub;
                  }

                  /// If the selected club is null, set using the default club of the user
                  if (selectedIdClub != null) {
                    user.selectedClub = clubs.firstWhere(
                        (club) => club.id == selectedIdClub,
                        orElse: () => clubs.first);
                  }

                  return user;
                });
          })

          /// Fetch the mails of the selected club of the user
          .switchMap((Profile user) {
            if (user.selectedClub == null) {
              return Stream.value(user);
            }
            return supabase
                .from('mails')
                .stream(primaryKey: ['id'])
                .eq('id_club_to',
                    user.selectedClub!.id) // Filter by selected club
                .order('created_at', ascending: false)
                .map((maps) => maps.map((map) => Mail.fromMap(map)).toList())
                .map((List<Mail> mails) {
                  print('Club mails: ${mails.length}');
                  user.selectedClub!.mails = mails;
                  return user;
                });
          })

          /// Fetch the players of the club
          .switchMap((Profile user) {
            if (user.selectedClub == null) {
              return Stream.value(user);
            }
            return supabase
                .from('players')
                .stream(primaryKey: ['id'])
                .eq('id_club', user.selectedClub!.id) // Filter by selected club
                .order('date_birth', ascending: true)
                .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
                .map((List<Player> players) {
                  print('Club Players: ${players.length}');
                  user.selectedClub!.players = players;
                  return user;
                });
          })

          /// Fetch the favorite players of the club
          .switchMap((Profile user) {
            if (user.selectedClub == null) {
              return Stream.value(user);
            }
            return supabase
                .from('players_favorite')
                .stream(primaryKey: ['id'])
                .eq('id_club', user.selectedClub!.id) // Filter by selected club
                .map((maps) =>
                    maps.map((map) => PlayerFavorite.fromMap(map)).toList())
                .map((List<PlayerFavorite> playersFavorite) {
                  print('Favorite Players: ${playersFavorite.length}');
                  user.selectedClub!.playersFavorite = playersFavorite;
                  return user;
                });
          })

          /// Fetch the poaching of the club
          .switchMap((Profile user) {
            if (user.selectedClub == null) {
              return Stream.value(user);
            }
            return supabase
                .from('players_poaching')
                .stream(primaryKey: ['id'])
                .eq('id_club', user.selectedClub!.id) // Filter by selected club
                .map((maps) =>
                    maps.map((map) => PlayerPoaching.fromMap(map)).toList())
                .map((List<PlayerPoaching> playersPoaching) {
                  print('Poaching Players: ${playersPoaching.length}');
                  user.selectedClub!.playersPoached = playersPoaching;
                  return user;
                });
          })

          /// Fetch the followed players (favorite and poaching) of the club
          .switchMap((Profile user) {
            if (user.selectedClub == null) {
              return Stream.value(user);
            }
            return supabase
                .from('players')
                .stream(primaryKey: ['id'])
                .inFilter('id', [
                  ...user.selectedClub!.playersFavorite
                      .map((pf) => pf.idPlayer),
                  ...user.selectedClub!.playersPoached.map((pp) => pp.idPlayer)
                ])
                .order('date_birth', ascending: true)
                .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
                .map((List<Player> players) {
                  print('Followed Players: ${players.length}');
                  for (PlayerFavorite pf
                      in user.selectedClub!.playersFavorite) {
                    Player? player = players
                        .firstWhere((player) => player.id == pf.idPlayer);
                    pf.player = player;
                  }
                  for (PlayerPoaching pp in user.selectedClub!.playersPoached) {
                    Player? player = players
                        .firstWhere((player) => player.id == pp.idPlayer);
                    pp.player = player;
                  }
                  return user;
                });
          })

          /// Listen to the stream
          .listen((Profile user) {
            print('### Received new data from session provider stream');
            // Update the user object with the new data
            this.user = user;
            // if (user.selectedClub == null && user.idDefaultClub != null) {
            //   providerSetSelectedClub(user.idDefaultClub!);
            // }
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
