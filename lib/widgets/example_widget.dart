import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/clubHelper.dart';

class ExampleWidget extends StatelessWidget {
  final Club club;

  ExampleWidget({required this.club});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example Widget'),
      ),
      body: Center(
        child: clubLeagueAndRankingListTile(context, club),
      ),
    );
  }
}
