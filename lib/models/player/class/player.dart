import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/functions/AgeAndBirth.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/models/player/player_dialog_training_coef.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/transfer_bid.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/widgets/countryStreamWidget.dart';
import 'package:opengoalz/widgets/playerTransferBidDialogBox.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart'
    as flutter_radar_chart;

part 'player_widget_helper.dart';
part 'player_widget_transfer.dart';
part 'player_widget_actions.dart';
part 'player_card_details.dart';
part 'player_card_stats.dart';
part 'player_card_history.dart';
part 'player_expenses_history.dart';

class Player {
  Club? club;
  List<TransferBid> transferBids = [];

  Player({
    required this.id,
    required this.created_at,
    required this.idClub,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.surName,
    required this.shirtNumber,
    required this.dateBirth,
    required this.idMultiverse,
    required this.multiverseSpeed,
    required this.idCountry,
    required this.expensesExpected,
    required this.expensesPayed,
    required this.expensesMissed,
    required this.trainingPointsUsed,
    required this.trainingCoef,
    required this.keeper,
    required this.defense,
    required this.playmaking,
    required this.passes,
    required this.scoring,
    required this.freekick,
    required this.winger,
    required this.dateEndInjury,
    required this.dateBidEnd,
    required this.dateArrival,
    required this.motivation,
    required this.form,
    required this.stamina,
    required this.experience,
    required this.notes,
    required this.performanceScore,
  });

  final int id;
  final DateTime created_at;
  final int? idClub;
  final String? userName;
  final String firstName;
  final String lastName;
  final String? surName;
  final int? shirtNumber;
  final DateTime dateBirth;
  final int idMultiverse;
  final int multiverseSpeed;
  final int? idCountry; //Shouldn't be nullable
  final int expensesExpected;
  final int expensesPayed;
  final int expensesMissed;
  final double trainingPointsUsed;
  final List<int> trainingCoef;
  final double keeper;
  final double defense;
  final double playmaking;
  final double passes;
  final double scoring;
  final double freekick;
  final double winger;
  final DateTime? dateEndInjury;
  final DateTime? dateBidEnd;
  final DateTime dateArrival;
  final double motivation;
  final double form;
  final double stamina;
  final double experience;
  final String? notes;
  final double performanceScore;

  Player.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        created_at = DateTime.parse(map['created_at']).toLocal(),
        idClub = map['id_club'],
        userName = map['username'],
        firstName = map['first_name'],
        lastName = map['last_name'],
        surName = map['surname'],
        shirtNumber = map['shirt_number'],
        dateBirth = DateTime.parse(map['date_birth']).toLocal(),
        idMultiverse = map['id_multiverse'],
        multiverseSpeed = map['multiverse_speed'],
        idCountry = map['id_country'],
        expensesExpected = map['expenses_expected'],
        expensesPayed = map['expenses_payed'],
        expensesMissed = map['expenses_missed'],
        trainingPointsUsed = (map['training_points_used'] as num).toDouble(),
        trainingCoef = List<int>.from(map['training_coef']),
        keeper = (map['keeper'] as num).toDouble(),
        defense = (map['defense'] as num).toDouble(),
        playmaking = (map['playmaking'] as num).toDouble(),
        passes = (map['passes'] as num).toDouble(),
        scoring = (map['scoring'] as num).toDouble(),
        freekick = (map['freekick'] as num).toDouble(),
        winger = (map['winger'] as num).toDouble(),
        form = (map['form'] as num).toDouble(),
        motivation = (map['motivation'] as num).toDouble(),
        stamina = (map['stamina'] as num).toDouble(),
        experience = (map['experience'] as num).toDouble(),
        dateEndInjury = map['date_end_injury'] != null
            ? DateTime.parse(map['date_end_injury']).toLocal()
            : null,
        dateBidEnd = map['date_bid_end'] != null
            ? DateTime.parse(map['date_bid_end']).toLocal()
            : null,
        dateArrival = DateTime.parse(map['date_arrival']).toLocal(),
        notes = map['notes'],
        performanceScore = (map['performance_score'] as num).toDouble();

  double get age {
    return calculateAge(dateBirth, multiverseSpeed);
  }

  // double get stats_average {
  //   return (keeper +
  //           defense +
  //           playmaking +
  //           passes +
  //           scoring +
  //           freekick +
  //           winger) /
  //       7.0;
  // }

  dynamic getPropertyValue(String propertyName) {
    switch (propertyName) {
      case 'id':
        return id;
      case 'created_at':
        return created_at;
      case 'idClub':
        return idClub;
      case 'userName':
        return userName;
      case 'firstName':
        return firstName;
      case 'lastName':
        return lastName;
      case 'surName':
        return surName;
      case 'shirtNumber':
        return shirtNumber;
      case 'dateBirth':
        return dateBirth;
      case 'idMmultiverse':
        return idMultiverse;
      case 'multiverseSpeed':
        return multiverseSpeed;
      case 'idCountry':
        return idCountry;
      case 'expensesExpected':
        return expensesExpected;
      case 'expensesPayed':
        return expensesPayed;
      case 'expensesMissed':
        return expensesMissed;
      case 'trainingPointsUsed':
        return trainingPointsUsed;
      case 'keeper':
        return keeper;
      case 'defense':
        return defense;
      case 'playmaking':
        return playmaking;
      case 'passes':
        return passes;
      case 'scoring':
        return scoring;
      case 'freekick':
        return freekick;
      case 'winger':
        return winger;
      case 'dateEndInjury':
        return dateEndInjury;
      case 'dateBidEnd':
        return dateBidEnd;
      case 'dateArrival':
        return dateArrival;
      case 'motivation':
        return motivation;
      case 'form':
        return form;
      case 'stamina':
        return stamina;
      case 'experience':
        return experience;
      case 'notes':
        return notes;
      default:
        throw ArgumentError('Property not found');
    }
  }

  String getFullName() {
    return '$firstName ${lastName.toUpperCase()} ${surName != null ? '${surName!}' : ''}';
  }
}
