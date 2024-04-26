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
  final int idClub;
  const TransferPage({Key? key, required this.idClub}) : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute<void>(
      builder: (context) => TransferPage(idClub: idClub),
    );
  }

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  late Stream<List<int>> _IdPlayersTransferStream;
  late Stream<List<Player>> _playerStream;

  @override
  void initState() {
    super.initState();

    _IdPlayersTransferStream = supabase
        .from('transfers_bids')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.idClub)
        .map((maps) =>
            maps.map((map) => map['id_player'] as int).toSet().toList());

    _playerStream = _IdPlayersTransferStream.asyncExpand((playerIds) {
      print('testPierreG');
      return supabase
          .from('players')
          .stream(primaryKey: ['id'])
          .inFilter('id', playerIds)
          .order('date_birth', ascending: true)
          .map((maps) => maps.map((map) => Player.fromMap(map)).toList());
    }).asBroadcastStream();
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
