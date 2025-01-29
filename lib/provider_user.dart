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

class SessionProvider extends ChangeNotifier {
  Profile? user;

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
          .listen((Profile user) {
            this.user = user;
            notifyListeners();
            if (!completer.isCompleted) {
              completer.complete();
            }
            _fetchUserRelatedData(context, user, selectedIdClub);
          });
    } catch (error) {
      await handleFatalError(context, error.toString());
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    return completer.future;
  }

  void _fetchUserRelatedData(
      BuildContext context, Profile user, int? selectedIdClub) {
    _fetchUserMails(context, user);
    _fetchUserPlayers(context, user);
    _fetchUserClubs(context, user, selectedIdClub);
  }

  void _fetchUserMails(BuildContext context, Profile user) {
    supabase
        .from('mails')
        .stream(primaryKey: ['id'])
        .eq('username_to', user.username)
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => Mail.fromMap(map)).toList())
        .listen((List<Mail> mails) {
          user.mails = mails;
          notifyListeners();
        });
  }

  void _fetchUserPlayers(BuildContext context, Profile user) {
    supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .eq('username', user.username)
        .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
        .listen((List<Player> players) {
          user.playersIncarnated = players;
          notifyListeners();
        });
  }

  void _fetchUserClubs(
      BuildContext context, Profile user, int? selectedIdClub) {
    supabase
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('username', user.username)
        .order('user_since', ascending: true)
        .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
        .listen((List<Club> clubs) {
          user.clubs = clubs;

          if (selectedIdClub == null) {
            selectedIdClub = user.idDefaultClub;
          }

          if (selectedIdClub != null) {
            user.selectedClub = clubs.firstWhere(
                (club) => club.id == selectedIdClub,
                orElse: () => clubs.first);
          }

          notifyListeners();
          _fetchClubRelatedData(context, user.selectedClub);
        });
  }

  void _fetchClubRelatedData(BuildContext context, Club? selectedClub) async {
    if (selectedClub == null) return;

    _fetchClubMails(context, selectedClub);
    _fetchClubPlayers(context, selectedClub);

    // Await the completion of both _fetchClubFavoritePlayers and _fetchClubPoachingPlayers
    await Future.wait([
      _fetchClubFavoritePlayers(context, selectedClub),
      _fetchClubPoachingPlayers(context, selectedClub),
    ]);

    // _fetchFollowedPlayers(context, selectedClub);
  }

  void _fetchClubMails(BuildContext context, Club selectedClub) {
    supabase
        .from('mails')
        .stream(primaryKey: ['id'])
        .eq('id_club_to', selectedClub.id)
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => Mail.fromMap(map)).toList())
        .listen((List<Mail> mails) {
          print('Club mails: ${mails.length}');
          selectedClub.mails = mails;
          notifyListeners();
        });
  }

  void _fetchClubPlayers(BuildContext context, Club selectedClub) {
    supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .eq('id_club', selectedClub.id)
        .order('date_birth', ascending: true)
        .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
        .listen((List<Player> players) {
          print('Club Players: ${players.length}');
          selectedClub.players = players;
          notifyListeners();
        });
  }

  Future<void> _fetchClubFavoritePlayers(
      BuildContext context, Club selectedClub) async {
    await supabase
        .from('players_favorite')
        .stream(primaryKey: ['id'])
        .eq('id_club', selectedClub.id)
        .map((maps) => maps.map((map) => PlayerFavorite.fromMap(map)).toList())
        .listen((List<PlayerFavorite> playersFavorite) {
          print('Favorite Players: ${playersFavorite.length}');
          selectedClub.playersFavorite = playersFavorite;
          notifyListeners();
        })
        .asFuture();
  }

  Future<void> _fetchClubPoachingPlayers(
      BuildContext context, Club selectedClub) async {
    await supabase
        .from('players_poaching')
        .stream(primaryKey: ['id'])
        .eq('id_club', selectedClub.id)
        .map((maps) => maps.map((map) => PlayerPoaching.fromMap(map)).toList())
        .listen((List<PlayerPoaching> playersPoaching) {
          print('Poaching Players: ${playersPoaching.length}');
          selectedClub.playersPoached = playersPoaching;
          notifyListeners();
        })
        .asFuture();
  }

  void fetchFollowedPlayers(BuildContext context, Club selectedClub) {
    print([
      ...selectedClub.playersFavorite.map((pf) => pf.idPlayer),
      ...selectedClub.playersPoached.map((pp) => pp.idPlayer)
    ]);
    supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .inFilter('id', [
          ...selectedClub.playersFavorite.map((pf) => pf.idPlayer),
          ...selectedClub.playersPoached.map((pp) => pp.idPlayer)
        ])
        .order('date_birth', ascending: true)
        .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
        .listen((List<Player> players) {
          print('Followed Players: ${players.length}');
          for (PlayerFavorite pf in selectedClub.playersFavorite) {
            Player? player =
                players.firstWhere((player) => player.id == pf.idPlayer);
            pf.player = player;
          }
          for (PlayerPoaching pp in selectedClub.playersPoached) {
            Player? player =
                players.firstWhere((player) => player.id == pp.idPlayer);
            pp.player = player;
          }
          notifyListeners();
        });
  }
}
