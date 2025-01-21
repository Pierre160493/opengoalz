import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';

class PlayerPoaching {
  Player? player;

  final int id;
  final DateTime createdAt;
  final int idClub;
  final int idPlayer;
  final int promisedExpenses;
  final int promisedPrice;

  PlayerPoaching({
    required this.id,
    required this.createdAt,
    required this.idClub,
    required this.idPlayer,
    required this.promisedExpenses,
    required this.promisedPrice,
  });

  factory PlayerPoaching.fromMap(Map<String, dynamic> map) {
    return PlayerPoaching(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      idClub: map['id_club'],
      idPlayer: map['id_player'],
      promisedExpenses: map['promised_expenses'],
      promisedPrice: map['promised_price'],
    );
  }
}

Widget getPlayersPoachingWidget(List<PlayerPoaching> playersPoaching) {
  return Column(
    children: [
      ListTile(
        leading: Icon(iconPoaching, color: Colors.green, size: iconSizeMedium),
        title: Text('Players Poaching'),
        subtitle: Text('List of players your scouting network are working on',
            style: styleItalicBlueGrey),
      ),
      ListView.builder(
        itemCount: playersPoaching.length,
        itemBuilder: (context, index) {
          final playerFavorite = playersPoaching[index];
          return ListTile(
            leading: Icon(playerFavorite.player!.getPlayerIcon()),
            title: playerFavorite.player!.getPlayerNameClickable(context),
            subtitle: Column(
              children: [
                Row(
                  children: [
                    Text('Promised Expenses: ', style: styleItalicBlueGrey),
                    Text(
                      playerFavorite.promisedExpenses.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text('Promised Price: ', style: styleItalicBlueGrey),
                    Text(
                      playerFavorite.promisedPrice.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(iconCancel, color: Colors.red),
              onPressed: () {
                print('Cancel poaching');
              },
            ),
          );
        },
      ),
    ],
  );
}
