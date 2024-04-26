import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/transfer_bid.dart';
import 'package:opengoalz/player/class/player.dart';
import 'package:opengoalz/player/player_card.dart';
import 'package:opengoalz/player/players_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:rxdart/rxdart.dart';

import '../constants.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (context) => TransferPage(),
    );
  }

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  late Stream<List<int>> _IdPlayersTransferStream;
  late Stream<List<Player>> _playerStream;
  late Stream<List<Club>> _clubStream;
  late Stream<List<TransferBid>> _transferBids;

  @override
  void initState() {
    super.initState();

    _IdPlayersTransferStream = supabase
        .from('transfers_bids')
        .stream(primaryKey: ['id'])
        .eq('id_club', 1)
        .map((maps) =>
            maps.map((map) => map['id_player'] as int).toSet().toList());

    _playerStream = _IdPlayersTransferStream.asyncExpand((playerIds) {
      return supabase
          .from('players')
          .stream(primaryKey: ['id'])
          .inFilter('id', playerIds)
          .order('date_birth', ascending: true)
          .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
    }).asBroadcastStream();

    // // Stream to fetch clubs from the list of clubs in the players list
    // _clubStream = _playerStream.switchMap((players) {
    //   final clubIds = players.map((player) => player.id_club).toSet().toList();
    //   return supabase
    //       .from('clubs')
    //       .stream(primaryKey: ['id'])
    //       .inFilter('id', clubIds.cast<Object>())
    //       .map((maps) => maps
    //           .map((map) => Club.fromMap(
    //                 map: map,
    //                 myUserId: supabase.auth.currentUser!.id,
    //               ))
    //           .toList());
    // });
    // // Combine player and club streams
    // _playerStream =
    //     _playerStream.switchMap((players) => _clubStream.map((clubs) {
    //           for (var player in players) {
    //             final clubData =
    //                 clubs.firstWhere((club) => club.id_club == player.id_club);
    //             player.club = clubData;
    //           }
    //           return players;
    //         }));

    // // Stream to fetch transfer bids for each player
    // _transferBids = _playerStream.switchMap((players) {
    //   final playerIds = players.map((player) => player.id).toSet().toList();
    //   return supabase
    //       .from('transfers_bids')
    //       .stream(primaryKey: ['id'])
    //       .inFilter('id_player', playerIds.cast<Object>())
    //       .order('count_bid', ascending: true)
    //       .map((maps) => maps.map((map) => TransferBid.fromMap(map)).toList());
    // });

    // // Combine player and transfer bids streams
    // _playerStream =
    //     _playerStream.switchMap((players) => _transferBids.map((transferBids) {
    //           for (var player in players) {
    //             player.transferBids.clear();
    //             player.transferBids.addAll(
    //                 transferBids.where((bid) => bid.idPlayer == player.id));
    //           }
    //           return players;
    //         }));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Player>>(
        stream: _playerStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('ERROR: ${snapshot.error}'),
            );
          } else {
            final List<Player> players = snapshot.data ?? [];
            if (players.isEmpty) {
              return const Center(
                child: Text('ERROR: No players found'),
              );
            } else {
              return Scaffold(
                  appBar: AppBar(
                    title: Column(
                      children: [
                        Text(
                          'Transfer Page',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Club Name',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  drawer: AppDrawer(),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final Player player = players[index];
                            return PlayerCard(
                                player: player,
                                number: players.length == 1 ? 0 : index + 1,
                                isExpanded: players.length == 1 ? true : false);
                          },
                        ),
                      )
                    ],
                  ));
            }
          }
        });
  }
}
