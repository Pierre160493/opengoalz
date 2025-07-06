import 'dart:async';

import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/transfer_bid.dart';
import 'package:opengoalz/constants.dart';
import 'package:rxdart/rxdart.dart';

class PlayerService {
  Stream<List<Player>> getPlayersStream(
      PlayerSearchCriterias searchCriterias, Profile user) {
    return Stream.fromFuture(searchCriterias.fetchPlayerIds())
        .switchMap((playerIds) {
      if (playerIds.isEmpty) {
        return Stream.value([]);
      }

      var stream = supabase
          .from('players')
          .stream(primaryKey: ['id'])
          .inFilter('id', playerIds)
          .order('date_birth', ascending: false)
          .map((maps) => maps.map((map) => Player.fromMap(map, user)).toList())
          .switchMap((List<Player> players) {
            if (players.isEmpty) return Stream.value(players);
            return supabase
                .from('transfers_bids')
                .stream(primaryKey: ['id'])
                .inFilter('id_player',
                    players.map((player) => player.id).toSet().toList())
                .order('created_at', ascending: true)
                .map((maps) =>
                    maps.map((map) => TransferBid.fromMap(map)).toList())
                .map((List<TransferBid> transfersBids) {
                  for (Player player in players) {
                    player.transferBids.clear();
                    player.transferBids.addAll(transfersBids
                        .where((bid) => bid.idPlayer == player.id));
                  }
                  return players;
                });
          })
          .switchMap((List<Player> players) {
            if (players.isEmpty) return Stream.value(players);
            final clubIds = players
                .map((p) => p.idClub)
                .whereType<
                    int>() // Use whereType to filter out nulls and cast to int.
                .toSet()
                .toList();
            if (clubIds.isEmpty) return Stream.value(players);
            return supabase
                .from('clubs')
                .stream(primaryKey: ['id'])
                .inFilter('id', clubIds)
                .map((maps) =>
                    maps.map((map) => Club.fromMap(map, user)).toList())
                .map((List<Club> clubs) {
                  for (Player player
                      in players.where((p) => p.idClub != null)) {
                    player.club =
                        clubs.firstWhere((club) => club.id == player.idClub);
                  }
                  return players;
                });
          });

      if (searchCriterias.onTransferList) {
        stream = stream.map((players) {
          players.sort((Player a, Player b) {
            if (a.dateBidEnd == null) return 1;
            if (b.dateBidEnd == null) return -1;
            return a.dateBidEnd!.compareTo(b.dateBidEnd!);
          });
          return players;
        });
      }

      return stream;
    });
  }
}
