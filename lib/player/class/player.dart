// ignore_for_file: non_constant_identifier_names

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/classes/transfer_bid.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/pages/club_page.dart';
import 'package:opengoalz/player/players_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'player_widget_helper.dart';
part 'player_widget_transfer.dart';
part 'player_widget_actions.dart';

class Player {
  Club? club;
  List<TransferBid> transferBids = [];

  Player({
    required this.id,
    required this.created_at,
    required this.idClub,
    required this.firstName,
    required this.lastName,
    required this.dateBirth,
    required this.idCountry,
    required this.keeper,
    required this.defense,
    required this.playmaking,
    required this.passes,
    required this.scoring,
    required this.freekick,
    required this.winger,
    required this.dateEndInjury,
    required this.dateFiring,
    required this.dateSell,
    required this.dateArrival,
    required this.stamina,
    required this.form,
    required this.experience,
  });

  final int id;
  final DateTime created_at;
  final int? idClub;
  final String firstName;
  final String lastName;
  final DateTime dateBirth;
  final int? idCountry; //Shouldn't be nullable
  final double keeper;
  final double defense;
  final double playmaking;
  final double passes;
  final double scoring;
  final double freekick;
  final double winger;
  final DateTime? dateEndInjury;
  final DateTime? dateFiring;
  final DateTime? dateSell;
  final DateTime dateArrival;
  final double stamina;
  final double form;
  final double experience;

  Player.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        created_at = DateTime.parse(map['created_at']),
        idClub = map['id_club'],
        firstName = map['first_name'],
        lastName = map['last_name'],
        dateBirth = DateTime.parse(map['date_birth']),
        idCountry = map['id_country'],
        keeper = (map['keeper'] as num).toDouble(),
        defense = (map['defense'] as num).toDouble(),
        playmaking = (map['playmaking'] as num).toDouble(),
        passes = (map['passes'] as num).toDouble(),
        scoring = (map['scoring'] as num).toDouble(),
        freekick = (map['freekick'] as num).toDouble(),
        winger = (map['winger'] as num).toDouble(),
        stamina = (map['stamina'] as num).toDouble(),
        form = (map['form'] as num).toDouble(),
        experience = (map['experience'] as num).toDouble(),
        dateEndInjury = map['date_end_injury'] != null
            ? DateTime.parse(map['date_end_injury'])
            : null,
        dateFiring = map['date_firing'] != null
            ? DateTime.parse(map['date_firing'])
            : null,
        dateSell =
            map['date_sell'] != null ? DateTime.parse(map['date_sell']) : null,
        dateArrival = DateTime.parse(map['date_arrival']);

  double get age {
    return DateTime.now().difference(dateBirth).inDays / 112.0;
  }

  double get stats_average {
    return (keeper +
            defense +
            playmaking +
            passes +
            scoring +
            freekick +
            winger) /
        7.0;
  }
}
