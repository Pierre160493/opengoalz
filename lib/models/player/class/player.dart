import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/functions/AgeAndBirth.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/player/playerCardTransferListTile.dart';
import 'package:opengoalz/models/player/playerWidgets.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/transfer_bid.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/widgets/countryListTile.dart';
import 'package:opengoalz/models/player/playerSellFireDialogBox.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'player_widget_helper.dart';
part 'player_widget_actions.dart';
part 'player_card_details.dart';

class Player {
  Club? club;
  List<TransferBid> transferBids = [];
  Multiverse? multiverse;
  bool? isFavorite;

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
    required this.transferPrice,
    required this.dateArrival,
    required this.motivation,
    required this.form,
    required this.stamina,
    required this.energy,
    required this.experience,
    required this.notes,
    required this.notesSmall,
    required this.performanceScore,
    required this.idGamesPlayed,
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
  final int? transferPrice;
  final DateTime dateArrival;
  final double motivation;
  final double form;
  final double stamina;
  final double energy;
  final double experience;
  final String notes;
  final String notesSmall;
  final double performanceScore;
  final List<int> idGamesPlayed;

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
        energy = (map['energy'] as num).toDouble(),
        experience = (map['experience'] as num).toDouble(),
        dateEndInjury = map['date_end_injury'] != null
            ? DateTime.parse(map['date_end_injury']).toLocal()
            : null,
        dateBidEnd = map['date_bid_end'] != null
            ? DateTime.parse(map['date_bid_end']).toLocal()
            : null,
        transferPrice = map['transfer_price'],
        dateArrival = DateTime.parse(map['date_arrival']).toLocal(),
        notes = map['notes'],
        notesSmall = map['notes_small'],
        performanceScore = (map['performance_score'] as num).toDouble(),
        idGamesPlayed = List<int>.from(map['id_games_played']);

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
      case 'energy':
        return energy;
      case 'experience':
        return experience;
      case 'notes':
        return notes;
      case 'notes_small':
        return notesSmall;
      default:
        throw ArgumentError('Property not found');
    }
  }

  String getFullName() {
    return '$firstName ${lastName.toUpperCase()}${surName != null ? ' (${surName!})' : ''}';
  }

  String getShortName() {
    return '${firstName[0].toUpperCase()}.${lastName.toUpperCase()}${surName != null ? ' (${surName!})' : ''}';
  }
}
